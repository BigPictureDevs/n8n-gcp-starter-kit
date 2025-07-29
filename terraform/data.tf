# data.tf

# Generate random strings for secure database credentials.
# This avoids ever having to write secrets in code.
resource "random_string" "db_user" {
  length  = 16
  special = false
  upper   = false
}

resource "random_string" "db_password" {
  length  = 32
  # Set special to false to generate a script-safe alphanumeric password.
  # This prevents special characters from breaking the 'sed' command in the startup script.
  special = false
}

# This data source finds your existing managed DNS zone in GCP.
data "google_dns_managed_zone" "zone" {
  name = var.managed_zone_name
}
