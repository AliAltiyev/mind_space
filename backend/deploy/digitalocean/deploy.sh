#!/bin/bash

# DigitalOcean deployment script for Mind Space Backend
# This script sets up the infrastructure on DigitalOcean

set -e

ENVIRONMENT=${1:-production}
DROPLET_SIZE=${2:-s-2vcpu-4gb}
REGION=${3:-nyc1}

echo "Deploying Mind Space Backend to DigitalOcean..."
echo "Environment: $ENVIRONMENT"
echo "Droplet Size: $DROPLET_SIZE"
echo "Region: $REGION"

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "doctl is not installed. Please install it first:"
    echo "https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Create load balancer
echo "Creating load balancer..."
LB_ID=$(doctl compute load-balancer create \
    --name "mind-space-lb-$ENVIRONMENT" \
    --region $REGION \
    --forwarding-rules entry_protocol:http,entry_port:80,target_protocol:http,target_port:8080 \
    --health-check protocol:http,port:8080,path:/api/health \
    --tag-name "mind-space-$ENVIRONMENT" \
    --format ID --no-header)

echo "Load balancer created: $LB_ID"

# Create database cluster
echo "Creating PostgreSQL database cluster..."
DB_ID=$(doctl databases create "mind-space-db-$ENVIRONMENT" \
    --engine pg \
    --version 15 \
    --region $REGION \
    --size db-s-2vcpu-2gb \
    --format ID --no-header)

echo "Database cluster created: $DB_ID"

# Create Redis cluster
echo "Creating Redis cluster..."
REDIS_ID=$(doctl databases create "mind-space-redis-$ENVIRONMENT" \
    --engine redis \
    --version 7 \
    --region $REGION \
    --size db-s-2vcpu-2gb \
    --format ID --no-header)

echo "Redis cluster created: $REDIS_ID"

# Create droplets
echo "Creating droplets..."
for i in 1 2; do
    DROPLET_NAME="mind-space-backend-$ENVIRONMENT-$i"
    
    doctl compute droplet create $DROPLET_NAME \
        --size $DROPLET_SIZE \
        --region $REGION \
        --image ubuntu-22-04-x64 \
        --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1) \
        --tag-names "mind-space-$ENVIRONMENT" \
        --user-data-file deploy/digitalocean/user-data.sh \
        --wait
    
    echo "Droplet $DROPLET_NAME created"
done

# Add droplets to load balancer
echo "Adding droplets to load balancer..."
DROPLET_IPS=$(doctl compute droplet list --tag-name "mind-space-$ENVIRONMENT" --format PublicIPv4 --no-header)

for IP in $DROPLET_IPS; do
    doctl compute load-balancer add-droplets $LB_ID --droplet-ids $(doctl compute droplet list --format ID,PublicIPv4 --no-header | grep $IP | awk '{print $1}')
done

echo "Deployment complete!"
echo "Load Balancer IP: $(doctl compute load-balancer get $LB_ID --format IP --no-header)"
echo "Database Host: $(doctl databases connection $DB_ID --format Host --no-header)"
echo "Redis Host: $(doctl databases connection $REDIS_ID --format Host --no-header)"

