#!/bin/bash

# Setup script for Mind Space Backend
# This script sets up the development environment

set -e

echo "Setting up Mind Space Backend..."

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "Error: Node.js 18 or higher is required"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "Please edit .env file with your configuration"
fi

# Create logs directory
mkdir -p logs

# Check if Docker is running
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo "Docker is running. Starting infrastructure..."
        docker-compose up -d postgres redis rabbitmq
        
        echo "Waiting for services to be ready..."
        sleep 5
        
        # Run database migrations
        echo "Running database migrations..."
        ./scripts/migrate.sh up
    else
        echo "Docker is not running. Please start Docker and run:"
        echo "  docker-compose up -d postgres redis rabbitmq"
    fi
else
    echo "Docker is not installed. Please install Docker to use the full setup."
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Start the development server: npm run dev"
echo "3. Or start with clustering: npm run start:cluster"


