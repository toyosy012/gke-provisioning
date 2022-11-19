resource "google_container_cluster" "training_cluster" {
  name     = "training-cluster"
  location = var.location

  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version = "1.23"

  network = var.gke_network_name
  subnetwork = var.gke_subnetwork_name
  enable_intranode_visibility = true

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes = true
    master_ipv4_cidr_block = "192.168.0.0/28"
  }

  master_authorized_networks_config {
  }
  ip_allocation_policy {
    cluster_secondary_range_name = var.pod_ip_range_name
    services_secondary_range_name = var.service_ip_range_name
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
