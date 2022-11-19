variable "CREDENTIALS_PATH" {
  type = string
  description = "Read the TF_VARS_CREDENTIALS_PATH variable by environment."
}

variable "PROJECT_ID" {
  type = string
  description = "Read the TF_VAR_PROJECT_ID variable by environment."
}

variable "PROJECT_NUMBER" {
  type = string
  description = "Read the TF_VAR_PROJECT_NUMBER variable by environment."
}

variable "BASTION_IMAGE_PROJECT" {
  type = string
  description = "Read the TF_VAR_BASTION_IMAGE_PROJECT variable by environment."
}

variable "BASTION_IMAGE_FAMILY" {
  type = string
  description = "Read the TF_VAR_BASTION_IMAGE_FAMILY variable by environment."
}

variable "provisioner_email" { type = string }

variable "bastion_hostname" { type = string }

variable "region" { type = string }

variable "zone" { type = string }

variable "gke_network_name" { type = string }

variable "gke_subnetwork_name" { type = string }

variable "account_id" { type = string }
