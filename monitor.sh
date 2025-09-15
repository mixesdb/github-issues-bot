#!/bin/bash

# GitHub Issues Bot Monitoring Script
# This script helps monitor the bot's health and performance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[MONITOR]${NC} $1"
}

# Function to check PM2 status
check_pm2() {
    print_header "Checking PM2 Status"
    
    if command -v pm2 &> /dev/null; then
        pm2 list
        echo ""
        pm2 show github-issues-bot 2>/dev/null || print_warning "Bot not running in PM2"
    else
        print_error "PM2 not installed"
    fi
}

# Function to check Docker status
check_docker() {
    print_header "Checking Docker Status"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
        echo ""
        if docker-compose ps | grep -q "github-issues-bot"; then
            print_status "Bot container is running"
        else
            print_warning "Bot container not found"
        fi
    else
        print_error "Docker Compose not installed"
    fi
}

# Function to check systemd status
check_systemd() {
    print_header "Checking Systemd Status"
    
    if systemctl is-active --quiet github-issues-bot; then
        print_status "Bot service is active"
        systemctl status github-issues-bot --no-pager
    else
        print_warning "Bot service not active"
    fi
}

# Function to show recent logs
show_logs() {
    print_header "Recent Logs"
    
    # Try PM2 first
    if command -v pm2 &> /dev/null && pm2 list | grep -q "github-issues-bot"; then
        print_status "PM2 Logs (last 20 lines):"
        pm2 logs github-issues-bot --lines 20 --nostream
    # Try Docker
    elif command -v docker-compose &> /dev/null && docker-compose ps | grep -q "github-issues-bot"; then
        print_status "Docker Logs (last 20 lines):"
        docker-compose logs --tail=20 github-issues-bot
    # Try systemd
    elif systemctl is-active --quiet github-issues-bot; then
        print_status "Systemd Logs (last 20 lines):"
        journalctl -u github-issues-bot --lines=20 --no-pager
    else
        print_warning "No running bot instance found"
    fi
}

# Function to check system resources
check_resources() {
    print_header "System Resources"
    
    echo "Memory Usage:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h
    echo ""
    echo "CPU Load:"
    uptime
}

# Function to show help
show_help() {
    echo "GitHub Issues Bot Monitoring Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  pm2       Check PM2 status"
    echo "  docker    Check Docker status"
    echo "  systemd   Check systemd status"
    echo "  logs      Show recent logs"
    echo "  resources Show system resources"
    echo "  all       Check all deployment methods"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 pm2       # Check PM2 status"
    echo "  $0 logs      # Show recent logs"
    echo "  $0 all       # Check everything"
}

# Main script logic
case "${1:-}" in
    "pm2")
        check_pm2
        ;;
    "docker")
        check_docker
        ;;
    "systemd")
        check_systemd
        ;;
    "logs")
        show_logs
        ;;
    "resources")
        check_resources
        ;;
    "all")
        check_pm2
        echo ""
        check_docker
        echo ""
        check_systemd
        echo ""
        show_logs
        echo ""
        check_resources
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "")
        print_warning "No monitoring option specified!"
        echo ""
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
