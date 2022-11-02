variable "CREDENTIALS_PATH" {
  type = string
  description = "Read the TF_VARS_CREDENTIALS_PATH variable by environment."
}

variable "PROJECT_ID" {
  type = string
  description = "Read the TF_VAR_PROJECT_ID variable by environment."
}

variable "project" {
  type = object({
    region  = string
    zone    = string
  })
}
