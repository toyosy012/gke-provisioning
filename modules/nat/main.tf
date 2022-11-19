# パブリックIPを持たないVPCから外部に出るためのNAT
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  project = var.project_id
  region  = var.region
  network = var.gke_network_name
}

resource "google_compute_address" "nat_address" {
  name    = "nat-address"
  project = var.project_id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.nat_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
