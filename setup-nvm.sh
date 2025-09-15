#!/bin/bash

# NVM Setup Script for GitHub Issues Bot
# This script sets up NVM and Node.js for the GitHub user

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
    echo -e "${BLUE}[NVM SETUP]${NC} $1"
}

# Function to install NVM
install_nvm() {
    print_header "Installing NVM..."
    
    if [ -d "$HOME/.nvm" ]; then
        print_warning "NVM already installed at $HOME/.nvm"
        return 0
    fi
    
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_status "NVM installed successfully!"
}

# Function to install Node.js
install_node() {
    print_header "Installing Node.js 18 LTS..."
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install Node.js 18 LTS
    nvm install 18
    nvm use 18
    nvm alias default 18
    
    print_status "Node.js $(node --version) installed successfully!"
}

# Function to setup shell profile
setup_shell_profile() {
    print_header "Setting up shell profile..."
    
    # Determine shell profile
    if [ -n "$ZSH_VERSION" ]; then
        PROFILE="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        PROFILE="$HOME/.bashrc"
    else
        PROFILE="$HOME/.profile"
    fi
    
    # Add NVM to shell profile if not already present
    if ! grep -q "NVM_DIR" "$PROFILE" 2>/dev/null; then
        print_status "Adding NVM to $PROFILE..."
        cat >> "$PROFILE" << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
        print_status "NVM configuration added to $PROFILE"
    else
        print_warning "NVM already configured in $PROFILE"
    fi
}

# Function to verify installation
verify_installation() {
    print_header "Verifying installation..."
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Check Node.js
    if command -v node &> /dev/null; then
        print_status "Node.js version: $(node --version)"
    else
        print_error "Node.js not found!"
        return 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        print_status "npm version: $(npm --version)"
    else
        print_error "npm not found!"
        return 1
    fi
    
    # Check NVM
    if command -v nvm &> /dev/null; then
        print_status "NVM version: $(nvm --version)"
    else
        print_error "NVM not found!"
        return 1
    fi
    
    print_status "All tools verified successfully!"
}

# Function to show usage instructions
show_usage() {
    print_header "Usage Instructions"
    echo ""
    echo "After running this script, you may need to:"
    echo "1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Navigate to your project directory"
    echo "3. Run the deployment script: ./deploy.sh pm2"
    echo ""
    echo "To manually load NVM in the current session:"
    echo "  source ~/.nvm/nvm.sh"
    echo ""
    echo "To switch Node.js versions:"
    echo "  nvm use 18"
    echo "  nvm use 16"
    echo ""
    echo "To see installed Node.js versions:"
    echo "  nvm list"
}

# Main script logic
main() {
    print_header "Starting NVM setup for GitHub Issues Bot"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root!"
        print_error "Run it as the GitHub user instead."
        exit 1
    fi
    
    # Install NVM
    install_nvm
    
    # Install Node.js
    install_node
    
    # Setup shell profile
    setup_shell_profile
    
    # Verify installation
    verify_installation
    
    # Show usage instructions
    show_usage
    
    print_status "NVM setup completed successfully!"
    print_status "Please restart your terminal or run: source ~/.bashrc"
}

# Run main function
main "$@"
