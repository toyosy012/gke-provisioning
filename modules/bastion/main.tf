locals {
  bastion_hostname = "gke-bastion-host"
}

data "template_file" "startup_script" {
  template = <<-EOF
  $(gcloud info --format="value(basic.python_location)") -m pip install numpy
  sudo apt update -y
  sudo apt-get install -y tinyproxy
  sudo echo "Allow localhost" >> /etc/tinyproxy/tinyproxy.conf
  sudo service tinyproxy restart
  EOF
}

resource "google_service_account" "bastion" {
  account_id   = "bastion"
  display_name = "My Service Account For Bastion"
}

resource "google_compute_instance" "gke_bastion_host" {
  name         = var.bastion_hostname
  machine_type = "n1-standard-1"
  zone         = var.zone
  project      = var.PROJECT_ID
  tags = [
    "bastion"
  ]

  boot_disk {
    initialize_params {
      image = "${var.BASTION_IMAGE_PROJECT}/${var.BASTION_IMAGE_FAMILY}"
    }
  }

  metadata_startup_script = data.template_file.startup_script.rendered
  network_interface {
    network    = var.gke_network_name
    subnetwork = var.gke_subnetwork_name
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

resource "google_compute_firewall" "gke_bastion_firewall" {
  name    = "gke-bastion-network"
  network = var.gke_network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["bastion"]
  source_ranges = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
