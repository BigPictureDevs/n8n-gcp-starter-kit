# A firewall rule to allow HTTP and HTTPS traffic
resource "google_compute_firewall" "n8n_firewall" {
  name    = "${var.instance_name}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

# The Compute Engine VM instance
resource "google_compute_instance" "n8n_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      # Using Ubuntu 22.04 LTS for good Docker support
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // This assigns an ephemeral public IP
    }
  }

  # Use the standard 'startup-script' metadata key with templatefile.
  # This is the most reliable way to run a startup script on GCP.
  metadata = {
    startup-script = templatefile("${path.module}/startup-script.sh", {
      domain_name       = "${var.n8n_subdomain}.${var.domain_name}"
      letsencrypt_email = var.letsencrypt_email
      db_name           = "n8n"
      db_user           = random_string.db_user.result
      db_password       = random_string.db_password.result
    })
  }

  # Ensures the firewall rule is in place before the instance starts accepting traffic
  depends_on = [google_compute_firewall.n8n_firewall]
}

# Create the A record to point the subdomain to our new server
resource "google_dns_record_set" "n8n_dns" {
  name = "${var.n8n_subdomain}.${var.domain_name}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.zone.name
  rrdatas      = [google_compute_instance.n8n_instance.network_interface[0].access_config[0].nat_ip]
}
