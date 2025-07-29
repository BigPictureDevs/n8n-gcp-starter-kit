#!/bin/bash
# This script is executed on the first boot of the server.

# --- Log everything to a file for easier debugging ---
exec > >(tee /var/log/startup-script-output.log) 2>&1

echo "--- Starting startup script ---"

# --- Install Docker ---
echo "Updating packages and installing Docker..."
apt-get update -y
apt-get install -y docker.io
echo "Docker installation complete."

# --- Install latest Docker Compose ---
echo "Installing/Upgrading Docker Compose..."
# Remove the old version if it exists
apt-get remove docker-compose -y
# Download the latest stable release of Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Apply executable permissions to the binary
chmod +x /usr/local/bin/docker-compose
echo "Docker Compose installation complete. Version: $(docker-compose --version)"

# --- Add default user to docker group ---
echo "Adding default ubuntu user to docker group..."
usermod -aG docker ubuntu
echo "User added to docker group."

# --- Create application directory ---
echo "Creating /opt/n8n_data directory..."
mkdir -p /opt/n8n_data
echo "Directory created."

# --- Create docker-compose.yml from template ---
echo "Creating docker-compose.template.yml..."
cat <<'EOF' > /opt/n8n_data/docker-compose.template.yml
version: '3.8'

services:
  traefik:
    image: "traefik:v2.10"
    restart: always
    command:
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.email=__LETSENCRYPT_EMAIL__"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"

  postgres:
    image: postgres:15
    restart: always
    environment:
      - POSTGRES_DB=__DB_NAME__
      - POSTGRES_USER=__DB_USER__
      - POSTGRES_PASSWORD=__DB_PASSWORD__
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U __DB_USER__ -d __DB_NAME__"]
      interval: 10s
      timeout: 5s
      retries: 5

  n8n:
    # Pinning to a specific version is more stable than using 'latest'.
    image: docker.n8n.io/n8nio/n8n:1.105.0
    restart: always
    # The 'command' override is removed to allow the container to use its default entrypoint.
    environment:
      - N8N_HOST=__DOMAIN_NAME__
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://__DOMAIN_NAME__/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=__DB_NAME__
      - DB_POSTGRESDB_USER=__DB_USER__
      - DB_POSTGRESDB_PASSWORD=__DB_PASSWORD__
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(`__DOMAIN_NAME__`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=myresolver"
    volumes:
      - ./n8n-data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
EOF
echo "docker-compose.template.yml created."

# --- Substitute variables and create final docker-compose.yml ---
echo "Substituting variables..."
sed -e "s|__DOMAIN_NAME__|${domain_name}|g" \
    -e "s|__LETSENCRYPT_EMAIL__|${letsencrypt_email}|g" \
    -e "s|__DB_NAME__|${db_name}|g" \
    -e "s|__DB_USER__|${db_user}|g" \
    -e "s|__DB_PASSWORD__|${db_password}|g" \
    /opt/n8n_data/docker-compose.template.yml > /opt/n8n_data/docker-compose.yml
echo "docker-compose.yml created."

# --- Set correct permissions for n8n data directory ---
echo "Setting permissions for n8n data volume..."
mkdir -p /opt/n8n_data/n8n-data
chown -R 1000:1000 /opt/n8n_data/n8n-data
echo "Permissions set."

# --- Start the application stack ---
echo "Starting docker-compose stack..."
cd /opt/n8n_data && docker-compose up -d
echo "--- Startup script finished ---"
