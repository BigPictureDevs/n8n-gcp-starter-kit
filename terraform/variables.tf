variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID to deploy resources in."
}

variable "gcp_credentials_file" {
  type        = string
  description = "Path to the GCP service account JSON key file."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy in."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The GCP zone to deploy in."
  default     = "us-central1-a"
}

variable "instance_name" {
  type        = string
  description = "Name for the Compute Engine VM."
  default     = "n8n-server"
}

variable "machine_type" {
  type        = string
  description = "The machine type for the VM. e2-medium is a good start."
  default     = "e2-medium"
}

variable "managed_zone_name" {
  type        = string
  description = "The name of the managed zone in GCP Cloud DNS (e.g., 'your-domain-com')."
}

variable "domain_name" {
  type        = string
  description = "Your root domain name (e.g., 'example.com')."
}

variable "n8n_subdomain" {
  type        = string
  description = "The subdomain for n8n (e.g., 'n8n'). The final URL will be n8n.example.com."
  default     = "n8n"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt SSL certificate registration."
}