resource "google_service_account" "gke-provisioner" {
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
  role   = each.value
  member = "serviceAccount:${google_service_account.gke-provisioner.email}"
  project = var.PROJECT_ID
}
