output "n8n_url" {
  description = "The URL for your new n8n instance."
  value       = "https://${var.n8n_subdomain}.${var.domain_name}"
}

output "instance_ip" {
  description = "The public IP address of the n8n server."
  value       = google_compute_instance.n8n_instance.network_interface[0].access_config[0].nat_ip
}