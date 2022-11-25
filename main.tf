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
  project_number        = var.PROJECT_NUMBER
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
