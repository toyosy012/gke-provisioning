variable "CREDENTIALS_PATH" {
  type        = string
  description = "Read the TF_VARS_CREDENTIALS_PATH variable by environment."
}

variable "PROJECT_ID" {
  type        = string
  description = "Read the TF_VAR_PROJECT_ID variable by environment."
}

variable "PROJECT_NUMBER" {
  type        = string
  description = "Read the TF_VAR_PROJECT_NUMBER variable by environment."
}

variable "BASTION_IMAGE_PROJECT" {
  type        = string
  description = "Read the TF_VAR_BASTION_IMAGE_PROJECT variable by environment."
}

variable "BASTION_IMAGE_FAMILY" {
  type        = string
  description = "Read the TF_VAR_BASTION_IMAGE_FAMILY variable by environment."
}

variable "PROVISIONER_SERVICE_ACCOUNT_NAME" {
  type        = string
  description = "Read the TF_VAR_PROVISIONER_SERVICE_ACCOUNT_NAME variable by environment."
}

variable "project" {
  type = object({
    region = string
    zone   = string
  })
}

variable "location" { type = string }
variable "bastion_hostname" { type = string }
