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
