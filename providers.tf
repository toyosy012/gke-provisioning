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
  credentials = file(var.CREDENTIALS_PATH)
  project     = var.PROJECT_ID
  region      = var.project.region
  zone        = var.project.zone
}
