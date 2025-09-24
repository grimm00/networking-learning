#!/bin/bash

# Networking Learning Project - Uninstall Script
# This script removes the project and all its components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project information
PROJECT_NAME="Networking Learning Project"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$PROJECT_DIR/venv"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Confirmation prompt
confirm_uninstall() {
    echo -e "${YELLOW}This will completely remove the $PROJECT_NAME and all its components:${NC}"
    echo ""
    echo "  • Python virtual environment (venv/)"
    echo "  • Docker containers and images"
    echo "  • Docker networks and volumes"
    echo "  • Project files and directories"
    echo "  • Git repository (if --git flag is used)"
    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        echo -e "${YELLOW}Uninstall cancelled.${NC}"
        exit 0
    fi
}

# Check if running from project root
check_project_root() {
    if [ ! -f "$PROJECT_DIR/README.md" ] || [ ! -f "$PROJECT_DIR/package.json" ]; then
        print_error "This script must be run from the project root directory"
        print_info "Expected files not found: README.md, package.json"
        exit 1
    fi
}

# Stop and remove Docker containers
cleanup_docker() {
    print_header "Cleaning up Docker components"
    
    # Stop all project containers
    print_info "Stopping Docker containers..."
    if docker-compose down 2>/dev/null; then
        print_success "Stopped main project containers"
    else
        print_warning "No main project containers to stop"
    fi
    
    # Stop module containers
    for module in modules/*/; do
        if [ -f "$module/docker-compose.yml" ]; then
            module_name=$(basename "$module")
            print_info "Stopping $module_name containers..."
            if docker-compose -f "$module/docker-compose.yml" down 2>/dev/null; then
                print_success "Stopped $module_name containers"
            else
                print_warning "No $module_name containers to stop"
            fi
        fi
    done
    
    # Remove project-specific images
    print_info "Removing project-specific Docker images..."
    local images_removed=0
    
    # Remove images with project name or common tags
    for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(networking|net-practice|coredns|nginx|apache)" 2>/dev/null || true); do
        if docker rmi "$image" 2>/dev/null; then
            print_success "Removed image: $image"
            ((images_removed++))
        fi
    done
    
    if [ $images_removed -eq 0 ]; then
        print_warning "No project-specific images found to remove"
    fi
    
    # Remove project-specific networks
    print_info "Removing project-specific Docker networks..."
    local networks_removed=0
    
    for network in $(docker network ls --format "{{.Name}}" | grep -E "(networking|dns-network|http-network)" 2>/dev/null || true); do
        if docker network rm "$network" 2>/dev/null; then
            print_success "Removed network: $network"
            ((networks_removed++))
        fi
    done
    
    if [ $networks_removed -eq 0 ]; then
        print_warning "No project-specific networks found to remove"
    fi
    
    # Remove project-specific volumes
    print_info "Removing project-specific Docker volumes..."
    local volumes_removed=0
    
    for volume in $(docker volume ls --format "{{.Name}}" | grep -E "(networking|dns|http)" 2>/dev/null || true); do
        if docker volume rm "$volume" 2>/dev/null; then
            print_success "Removed volume: $volume"
            ((volumes_removed++))
        fi
    done
    
    if [ $volumes_removed -eq 0 ]; then
        print_warning "No project-specific volumes found to remove"
    fi
}

# Remove Python virtual environment
cleanup_venv() {
    print_header "Cleaning up Python virtual environment"
    
    if [ -d "$VENV_DIR" ]; then
        print_info "Removing Python virtual environment..."
        rm -rf "$VENV_DIR"
        print_success "Removed virtual environment: $VENV_DIR"
    else
        print_warning "No virtual environment found to remove"
    fi
}

# Remove project files
cleanup_project_files() {
    print_header "Cleaning up project files"
    
    # Remove common build/cache directories
    local dirs_to_remove=(
        "venv"
        "__pycache__"
        "*.pyc"
        "*.pyo"
        ".pytest_cache"
        ".coverage"
        "htmlcov"
        "dist"
        "build"
        "*.egg-info"
    )
    
    for pattern in "${dirs_to_remove[@]}"; do
        if [ -e "$PROJECT_DIR/$pattern" ] || ls "$PROJECT_DIR/$pattern" 2>/dev/null; then
            print_info "Removing $pattern..."
            rm -rf "$PROJECT_DIR/$pattern"
            print_success "Removed $pattern"
        fi
    done
    
    # Remove any temporary files
    find "$PROJECT_DIR" -name "*.tmp" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "*.log" -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name ".DS_Store" -delete 2>/dev/null || true
}

# Remove Git repository (optional)
cleanup_git() {
    if [ "$1" = "--git" ]; then
        print_header "Cleaning up Git repository"
        
        if [ -d "$PROJECT_DIR/.git" ]; then
            print_info "Removing Git repository..."
            rm -rf "$PROJECT_DIR/.git"
            print_success "Removed Git repository"
        else
            print_warning "No Git repository found to remove"
        fi
    fi
}

# Show cleanup summary
show_summary() {
    print_header "Uninstall Summary"
    
    echo -e "${GREEN}Successfully removed:${NC}"
    echo "  • Python virtual environment"
    echo "  • Docker containers and images"
    echo "  • Docker networks and volumes"
    echo "  • Project build artifacts"
    echo "  • Temporary files"
    
    if [ "$1" = "--git" ]; then
        echo "  • Git repository"
    fi
    
    echo ""
    echo -e "${BLUE}Project files remain in: $PROJECT_DIR${NC}"
    echo -e "${YELLOW}To completely remove the project, delete the entire directory:${NC}"
    echo -e "${YELLOW}  rm -rf $PROJECT_DIR${NC}"
    echo ""
    echo -e "${GREEN}Uninstall completed successfully!${NC}"
}

# Main function
main() {
    print_header "$PROJECT_NAME - Uninstaller"
    
    # Parse arguments
    local remove_git=false
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --git)
                remove_git=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --git     Also remove the Git repository"
                echo "  --force   Skip confirmation prompt"
                echo "  --help    Show this help message"
                echo ""
                echo "This script removes the $PROJECT_NAME and all its components."
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Check if running from project root
    check_project_root
    
    # Confirm uninstall unless --force is used
    if [ "$force" != "true" ]; then
        confirm_uninstall
    fi
    
    # Perform cleanup
    cleanup_docker
    cleanup_venv
    cleanup_project_files
    cleanup_git $remove_git
    
    # Show summary
    show_summary $remove_git
}

# Run main function with all arguments
main "$@"
