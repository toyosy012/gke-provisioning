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
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_provisioner.email}"
  project = var.PROJECT_NUMBER
}

module "network" {
  source   = "./modules/network"
  location = var.location
}

module "gke_cluster" {
  source                = "./modules/gke"
  location              = var.location
  gke_network_name      = module.network.training_network_name
  gke_subnetwork_name   = module.network.training_subnetwork_name
  pod_ip_range_name     = module.network.pod_ip_range_name
  service_ip_range_name = module.network.service_ip_range_name
}

module "bastion_host" {
  source                = "./modules/bastion"
  BASTION_IMAGE_FAMILY  = var.BASTION_IMAGE_FAMILY
  BASTION_IMAGE_PROJECT = var.BASTION_IMAGE_PROJECT
  CREDENTIALS_PATH      = var.CREDENTIALS_PATH
  PROJECT_ID            = var.PROJECT_ID
  PROJECT_NUMBER        = var.PROJECT_NUMBER
  bastion_hostname      = var.bastion_hostname
  gke_network_name      = module.network.training_network_name
  gke_subnetwork_name   = module.network.training_subnetwork_name
  provisioner_email     = google_service_account.gke_provisioner.email
  account_id            = var.PROVISIONER_SERVICE_ACCOUNT_NAME
  zone                  = var.project.zone
  region                = var.project.region
}

module "nat" {
  source = "./modules/nat"

  gke_network_name = module.network.training_network_name
  project_id       = var.PROJECT_ID
  region           = var.project.region
}
