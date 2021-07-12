resource "google_compute_instance" "boundary-demo-gcp" {
  name         = "boundary-demo"
  machine_type = var.gcp_machine_type
  zone         = "asia-northeast1-a"
  tags         = google_compute_firewall.boundary-demo-gcp-fw.source_tags
  network_interface {
    subnetwork = "default"
    access_config {
    }
  }
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  metadata_startup_script = data.template_file.init_gcp.rendered

}

data "template_file" "init_gcp" {
  template = file("setup-gcp.sh")
  vars = {
    ca_key = file("../../trusted-user-ca-keys.pem")
  }
}

resource "google_compute_firewall" "boundary-demo-gcp-fw" {
  name    = "boundary-demo-gcp"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["hashi"]
}
