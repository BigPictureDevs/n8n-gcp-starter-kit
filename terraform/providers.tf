terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  credentials = file(var.gcp_credentials_file)
  region      = var.region
  zone        = var.zone
}