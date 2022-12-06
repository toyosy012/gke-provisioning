output "training_network_name" {
  value = google_compute_network.training_gke.name
}

output "training_subnetwork_name" {
  value = google_compute_subnetwork.training_gke.name
}

output "pod_ip_range_name" {
  value = google_compute_subnetwork.training_gke.secondary_ip_range.0.range_name
}

output "service_ip_range_name" {
  value = google_compute_subnetwork.training_gke.secondary_ip_range.1.range_name
}
