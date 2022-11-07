resource "google_service_account" "gke-provisioner" {
  account_id   = "gke-provisioner"
  display_name = "gke-provisioner"
  description  = "A service account for GKE"
}

resource "google_project_iam_member" "gke_provisioning_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ])
  role   = each.value
  member = "serviceAccount:${google_service_account.gke-provisioner.email}"
  project = var.PROJECT_NUMBER
}

resource "google_container_cluster" "training_cluster" {
  name     = "training-cluster"
  location = var.location

  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version = "1.23"

  network = google_compute_network.gke_network.name
  subnetwork = google_compute_subnetwork.gke_subnetwork.name

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes = true
    master_ipv4_cidr_block = "192.168.0.0/28"
  }

  master_authorized_networks_config {
  }
  ip_allocation_policy {
    cluster_secondary_range_name = google_compute_subnetwork.gke_subnetwork.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.gke_subnetwork.secondary_ip_range.1.range_name
  }
}

resource "google_container_node_pool" "training_nodes" {
  cluster = google_container_cluster.training_cluster.name
  name = "training-node-pool"

  location = var.location
  node_count = 1
  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes"
  display_name = "My Service Account For My Cluster Nodes"
}

resource "google_compute_network" "gke_network" {
  name                    = "training-gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name   = "training-gke-subnetwork"
  region = var.location

  # サブネットで使用したい内部IPアドレスの範囲を指定する
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.gke_network.self_link

  # CloudLoggingにFlowLogログを出力したい場合は設定する
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  secondary_ip_range {
    range_name    = "training-gke-subnet-for-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "training-gke-subnet-for-services"
    ip_cidr_range = "10.2.0.0/16"
  }

  private_ip_google_access = true
}

resource "google_service_account" "bastion" {
  account_id   = "bastion"
  display_name = "Bastion Server For Private GKE Cluster"
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

resource "google_compute_instance" "gke_bastion_host" {
  name         = var.bastion_hostname
  machine_type = "n1-standard-1"
  zone         = var.project.zone
  project      = var.PROJECT_NUMBER
  tags = [
    "bastion"
  ]

  boot_disk {
    initialize_params {
      image = var.BASTION_IMAGE
    }
  }

  metadata_startup_script = data.template_file.startup_script.rendered
  network_interface {
    network = google_compute_network.gke_network.name
    subnetwork = google_compute_subnetwork.gke_subnetwork.name
  }

  allow_stopping_for_update = true

  service_account {
    email = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
  scheduling {
    preemptible = true
    automatic_restart = false
  }

  provisioner "local-exec" {
    command = <<EOF
        READY=""
        for i in $(seq 1 20); do
          if gcloud compute ssh ${var.bastion_hostname} --project ${var.PROJECT_ID} --zone ${var.project.zone} --command uptime; then
            READY="yes"
            break;
          fi
          echo "Waiting for ${var.bastion_hostname} to initialize..."
          sleep 10;
        done
        if [[ -z $READY ]]; then
          echo "${var.bastion_hostname} failed to start in time."
          echo "Please verify that the instance starts and then re-run `terraform apply`"
          exit 1
        fi
EOF
  }

}
