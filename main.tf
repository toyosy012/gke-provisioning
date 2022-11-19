resource "google_service_account" "gke_provisioner" {
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
  member = "serviceAccount:${google_service_account.gke_provisioner.email}"
  project = var.PROJECT_NUMBER
}

resource "google_container_cluster" "training_cluster" {
  name     = "training-cluster"
  location = var.location

  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version = "1.23"

  network = google_compute_network.training_gke.name
  subnetwork = google_compute_subnetwork.training_gke.name
  enable_intranode_visibility = true

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes = true
    master_ipv4_cidr_block = "192.168.0.0/28"
  }

  master_authorized_networks_config {
  }
  ip_allocation_policy {
    cluster_secondary_range_name = google_compute_subnetwork.training_gke.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.training_gke.secondary_ip_range.1.range_name
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

resource "google_compute_network" "training_gke" {
  name                    = "training-gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "training_gke" {
  name   = "training-gke-subnetwork"
  region = var.location

  # サブネットで使用したい内部IPアドレスの範囲を指定する
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.training_gke.self_link

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

module "bastion_host" {
  source = "./modules/bastion"
  BASTION_IMAGE_FAMILY = var.BASTION_IMAGE_FAMILY
  BASTION_IMAGE_PROJECT = var.BASTION_IMAGE_PROJECT
  CREDENTIALS_PATH = var.CREDENTIALS_PATH
  PROJECT_ID = var.PROJECT_ID
  PROJECT_NUMBER = var.PROJECT_NUMBER
  bastion_hostname = var.bastion_hostname
  gke_network_name = google_compute_network.training_gke.name
  gke_subnetwork_name = google_compute_subnetwork.training_gke.name
  provisioner_email = google_service_account.gke_provisioner.email
  account_id = var.PROVISIONER_SERVICE_ACCOUNT_NAME
  zone = var.project.zone
  region = var.project.region
}

module "nat" {
  source = "./modules/nat"

  gke_network_name = google_compute_network.training_gke.name
  project_id       = var.PROJECT_ID
  region           = var.project.region
}
