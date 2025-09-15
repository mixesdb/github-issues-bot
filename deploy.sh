#!/bin/bash

# GitHub Issues Bot Deployment Script
# This script helps deploy the bot using either PM2 or Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found! Please create one with your environment variables."
    exit 1
fi

# Function to deploy with PM2
deploy_pm2() {
    print_status "Deploying with PM2..."
    
    # Install PM2 globally if not installed
    if ! command -v pm2 &> /dev/null; then
        print_status "Installing PM2 globally..."
        npm install -g pm2
    fi
    
    # Install dependencies
    print_status "Installing dependencies..."
    npm install
    
    # Build the project
    print_status "Building TypeScript project..."
    npm run build
    
    # Stop existing PM2 process if running
    pm2 stop github-issues-bot 2>/dev/null || true
    pm2 delete github-issues-bot 2>/dev/null || true
    
    # Start with PM2
    print_status "Starting bot with PM2..."
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 to start on boot
    pm2 startup
    
    print_status "Bot deployed successfully with PM2!"
    print_status "Use 'npm run pm2:logs' to view logs"
    print_status "Use 'npm run pm2:monit' to monitor the process"
}

# Function to deploy with Docker
deploy_docker() {
    print_status "Deploying with Docker..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed! Please install Docker first."
        exit 1
    fi
    
    # Check if docker-compose is installed
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed! Please install Docker Compose first."
        exit 1
    fi
    
    # Stop existing containers
    print_status "Stopping existing containers..."
    docker-compose down 2>/dev/null || true
    
    # Build and start containers
    print_status "Building and starting containers..."
    docker-compose up --build -d
    
    print_status "Bot deployed successfully with Docker!"
    print_status "Use 'docker-compose logs -f' to view logs"
    print_status "Use 'docker-compose ps' to check container status"
}

# Function to show help
show_help() {
    echo "GitHub Issues Bot Deployment Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  pm2     Deploy using PM2 process manager"
    echo "  docker  Deploy using Docker containers"
    echo "  help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 pm2     # Deploy with PM2"
    echo "  $0 docker  # Deploy with Docker"
}

# Main script logic
case "${1:-}" in
    "pm2")
        deploy_pm2
        ;;
    "docker")
        deploy_docker
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "")
        print_warning "No deployment method specified!"
        echo ""
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
