locals {
  bastion_hostname = "gke-bastion-host"
  region           = "asia-northeast1"
  zone             = "asia-northeast1-a"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.42.0"
    }
  }

  required_version = "~> 1.3.3"
}

provider "google" {
  project     = var.project_id
  region      = local.region
  zone        = local.zone
}

module "network" {
  source   = "./modules/network"
  location = local.region
}

module "gke_cluster" {
  source                = "./modules/gke"
  location              = local.region
  gke_network_name      = module.network.training_network_name
  gke_subnetwork_name   = module.network.training_subnetwork_name
  pod_ip_range_name     = module.network.pod_ip_range_name
  service_ip_range_name = module.network.service_ip_range_name
  project_number        = var.project_number
}

module "bastion_host" {
  source                = "./modules/bastion"
  image_family  = "ubuntu-os-cloud"
  image_project = "ubuntu-2004-lts"
  project_id            = var.project_id
  project_number        = var.project_number
  bastion_hostname      = local.bastion_hostname
  gke_network_name      = module.network.training_network_name
  gke_subnetwork_name   = module.network.training_subnetwork_name
  zone                  = local.zone
  region                = local.region
}

module "nat" {
  source = "./modules/nat"

  gke_network_name = module.network.training_network_name
  project_id       = var.project_id
  region           = local.region
}
