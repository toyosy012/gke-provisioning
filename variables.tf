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

variable "BASTION_IMAGE" {
  type = string
  description = "Read the TF_VAR_BASTION_IMAGE variable by environment."
}

variable "project" {
  type = object({
    region  = string
    zone    = string
  })
}

variable "location" { type = string }
variable "bastion_hostname" { type = string }
