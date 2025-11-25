#!/bin/bash

# User data script for DigitalOcean droplets
# This script runs when the droplet is first created

set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application directory
mkdir -p /opt/mind-space-backend
cd /opt/mind-space-backend

# Clone repository (replace with your actual repository)
# git clone https://github.com/your-org/mind-space-backend.git .

# Or copy files via SCP/rsync
# For now, we'll assume files are already there

# Set up environment
cat > .env << EOF
NODE_ENV=production
PORT=8080
POSTGRES_HOST=your-db-host
POSTGRES_PORT=25060
POSTGRES_DB=mind_space
POSTGRES_USER=your-db-user
POSTGRES_PASSWORD=your-db-password
REDIS_HOST=your-redis-host
REDIS_PORT=25061
REDIS_PASSWORD=your-redis-password
EOF

# Build and start services
docker-compose build
docker-compose up -d

# Set up log rotation
cat > /etc/logrotate.d/mind-space << EOF
/opt/mind-space-backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        docker-compose restart backend
    endscript
}
EOF

# Set up monitoring (optional)
# Install node exporter for Prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.1.linux-amd64*

# Create systemd service for node exporter
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Setup complete!"


