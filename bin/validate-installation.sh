#!/bin/bash

# Networking Learning Project - Installation Validation Script
# This script performs a dry run validation to ensure all components are properly connected

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counters
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
WARNINGS=0

# Print functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    VALIDATIONS_PASSED=$((VALIDATIONS_PASSED + 1))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    VALIDATIONS_FAILED=$((VALIDATIONS_FAILED + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Validation functions
validate_file_exists() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        print_success "$description exists: $file_path"
        return 0
    else
        print_error "$description missing: $file_path"
        return 1
    fi
}

validate_directory_exists() {
    local dir_path="$1"
    local description="$2"
    
    if [ -d "$dir_path" ]; then
        print_success "$description exists: $dir_path"
        return 0
    else
        print_error "$description missing: $dir_path"
        return 1
    fi
}

validate_symlink() {
    local link_path="$1"
    local target_path="$2"
    local description="$3"
    
    if [ -L "$link_path" ]; then
        local actual_target=$(readlink "$link_path")
        if [ "$actual_target" = "$target_path" ]; then
            print_success "$description: $link_path -> $target_path"
            return 0
        else
            print_error "$description broken: $link_path -> $actual_target (expected: $target_path)"
            return 1
        fi
    else
        print_error "$description not a symlink: $link_path"
        return 1
    fi
}

validate_individual_script() {
    local script_path="$1"
    local description="$2"
    
    if [ ! -f "$script_path" ]; then
        print_error "$description not found: $script_path"
        return 1
    fi
    
    # Check for hardcoded old paths
    local old_paths=("01-basics" "02-protocols" "03-docker-networks" "04-network-analysis" "05-dns-server" "06-http-servers" "06-security" "07-advanced")
    
    for old_path in "${old_paths[@]}"; do
        # Check for standalone old paths (not part of modules/ path)
        if grep -q "[^/]$old_path[^/]" "$script_path" 2>/dev/null; then
            print_warning "$description contains old path reference: $old_path"
        fi
    done
    
    # Check for correct module references
    if grep -q "modules/" "$script_path" 2>/dev/null; then
        print_success "$description uses correct modules/ path"
    else
        print_warning "$description may not use modules/ path structure"
    fi
    
    return 0
}

# Main validation functions
validate_project_structure() {
    print_header "Validating Project Structure"
    
    # Core project files
    validate_file_exists "README.md" "Main README"
    validate_file_exists "docker-compose.yml" "Docker Compose file"
    validate_file_exists "requirements.txt" "Python requirements"
    validate_file_exists "package.json" "Package configuration"
    
    # Core directories
    validate_directory_exists "bin" "Bin directory"
    validate_directory_exists "scripts" "Scripts directory"
    validate_directory_exists "modules" "Modules directory"
    validate_directory_exists "docs" "Documentation directory"
    validate_directory_exists "admin" "Admin directory"
    
    # Module directories
    local modules=("01-basics" "02-protocols" "03-docker-networks" "04-network-analysis" "05-dns-server" "06-http-servers" "06-security" "07-advanced")
    
    for module in "${modules[@]}"; do
        validate_directory_exists "modules/$module" "Module: $module"
    done
}

validate_script_links() {
    print_header "Validating Script Symbolic Links"
    
    # Check all symbolic links in modules
    find modules -type l | while read -r link; do
        local target=$(readlink "$link")
        local expected_target=""
        
        # Determine expected target based on link location
        # All modules are at modules/XX-name/level/ so they need ../../../scripts/
        expected_target="../../../scripts/$(basename "$link")"
        
        if [ -n "$expected_target" ]; then
            validate_symlink "$link" "$expected_target" "Script link: $(basename "$link")"
        fi
    done
}

validate_script_path_references() {
    print_header "Validating Script Path References"
    
    # Check Python scripts for correct path references
    local python_scripts=(
        "scripts/http-server-manager.py"
        "scripts/dns-server-manager.py"
        "scripts/interface-analyzer.py"
        "scripts/dns-analyzer.py"
        "scripts/http-analyzer.py"
        "scripts/ssh-analyzer.py"
        "scripts/ntp-analyzer.py"
        "scripts/tcpdump-analyzer.py"
        "scripts/arp-simulator.py"
    )
    
    for script in "${python_scripts[@]}"; do
        if [ -f "$script" ]; then
            validate_individual_script "$script" "Python script: $(basename "$script")"
        fi
    done
    
    # Check shell scripts for correct path references
    local shell_scripts=(
        "bin/start-module.sh"
        "bin/check-ports.sh"
        "bin/test-installation.sh"
        "bin/install.sh"
    )
    
    for script in "${shell_scripts[@]}"; do
        if [ -f "$script" ]; then
            validate_individual_script "$script" "Shell script: $(basename "$script")"
        fi
    done
}

validate_docker_references() {
    print_header "Validating Docker Configuration References"
    
    # Check main docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        if grep -q "modules/" docker-compose.yml; then
            print_success "Main docker-compose.yml uses modules/ paths"
        else
            print_warning "Main docker-compose.yml may not use modules/ paths"
        fi
    fi
    
    # Check module docker-compose files
    local module_docker_files=(
        "modules/05-dns-server/docker-compose.yml"
        "modules/06-http-servers/docker-compose.yml"
    )
    
    for docker_file in "${module_docker_files[@]}"; do
        if [ -f "$docker_file" ]; then
            print_success "Module Docker file exists: $docker_file"
        else
            print_error "Module Docker file missing: $docker_file"
        fi
    done
}

validate_documentation_links() {
    print_header "Validating Documentation Links"
    
    # Check README.md for correct module references
    if [ -f "README.md" ]; then
        if grep -q "modules/" README.md; then
            print_success "README.md uses modules/ structure"
        else
            print_warning "README.md may not use modules/ structure"
        fi
        
        # Check for broken internal links
        if grep -q "\[.*\]([^h].*\.md)" README.md; then
            print_warning "README.md may contain relative links that need updating"
        fi
    fi
    
    # Check module README files
    find modules -name "README.md" | while read -r readme; do
        if [ -f "$readme" ]; then
            print_success "Module README exists: $readme"
        fi
    done
}

validate_script_dependencies() {
    print_header "Validating Script Dependencies"
    
    # Check if scripts can find their dependencies
    local scripts_to_test=(
        "scripts/interface-analyzer.py"
        "scripts/dns-analyzer.py"
        "scripts/http-analyzer.py"
        "scripts/ssh-analyzer.py"
        "scripts/ntp-analyzer.py"
        "scripts/tcpdump-analyzer.py"
    )
    
    for script in "${scripts_to_test[@]}"; do
        if [ -f "$script" ]; then
            if python3 "$script" --help >/dev/null 2>&1; then
                print_success "Script executable: $(basename "$script")"
            else
                print_error "Script not executable: $(basename "$script")"
            fi
        fi
    done
}

validate_module_consistency() {
    print_header "Validating Module Consistency"
    
    # Check that each module has expected structure
    local modules=("01-basics" "02-protocols" "03-docker-networks" "04-network-analysis" "05-dns-server" "06-http-servers" "06-security" "07-advanced")
    
    for module in "${modules[@]}"; do
        local module_path="modules/$module"
        
        if [ -d "$module_path" ]; then
            print_success "Module directory exists: $module"
            
            # Check for README
            if [ -f "$module_path/README.md" ]; then
                print_success "  └─ README.md exists"
            else
                print_warning "  └─ README.md missing"
            fi
            
            # Check for Docker explanation (for applicable modules)
            if [[ "$module" == "05-dns-server" ]] || [[ "$module" == "06-http-servers" ]]; then
                if [ -f "$module_path/DOCKER_EXPLAINED.md" ]; then
                    print_success "  └─ DOCKER_EXPLAINED.md exists"
                else
                    print_warning "  └─ DOCKER_EXPLAINED.md missing"
                fi
            fi
            
            # Check for docker-compose.yml (for applicable modules)
            if [[ "$module" == "05-dns-server" ]] || [[ "$module" == "06-http-servers" ]]; then
                if [ -f "$module_path/docker-compose.yml" ]; then
                    print_success "  └─ docker-compose.yml exists"
                else
                    print_warning "  └─ docker-compose.yml missing"
                fi
            fi
        else
            print_error "Module directory missing: $module"
        fi
    done
}

validate_port_consistency() {
    print_header "Validating Port Configuration Consistency"
    
    # Check for port conflicts in documentation
    if [ -f "docs/guides/PORT_MANAGEMENT.md" ]; then
        print_success "Port management documentation exists"
        
        # Check if port ranges are consistent
        if grep -q "8090-8093" docs/guides/PORT_MANAGEMENT.md; then
            print_success "HTTP module ports documented correctly"
        else
            print_warning "HTTP module ports may not be documented correctly"
        fi
    else
        print_error "Port management documentation missing"
    fi
}

# Main validation function
main() {
    print_header "Networking Learning Project - Installation Validation"
    echo "This script validates that all components are properly connected after reorganization."
    echo ""
    
    validate_project_structure
    echo ""
    
    validate_script_links
    echo ""
    
    validate_script_path_references
    echo ""
    
    validate_docker_references
    echo ""
    
    validate_documentation_links
    echo ""
    
    validate_script_dependencies
    echo ""
    
    validate_module_consistency
    echo ""
    
    validate_port_consistency
    echo ""
    
    # Summary
    print_header "Validation Summary"
    echo "Total validations: $((VALIDATIONS_PASSED + VALIDATIONS_FAILED))"
    echo "Passed: $VALIDATIONS_PASSED"
    echo "Failed: $VALIDATIONS_FAILED"
    echo "Warnings: $WARNINGS"
    echo ""
    
    if [ $VALIDATIONS_FAILED -eq 0 ]; then
        print_success "All validations passed! Installation is properly configured."
        echo ""
        echo "You can now:"
        echo "  - Start modules: ./bin/start-module.sh [module] start"
        echo "  - Run tests: ./bin/test-installation.sh"
        echo "  - Check ports: ./bin/check-ports.sh"
        echo "  - Use scripts: python3 scripts/[script-name].py"
    else
        print_error "Some validations failed. Please check the errors above."
        echo ""
        echo "Common fixes:"
        echo "  - Update hardcoded paths in scripts"
        echo "  - Fix broken symbolic links"
        echo "  - Update documentation references"
        echo "  - Ensure all modules have required files"
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo ""
        print_warning "There are $WARNINGS warnings. These may need attention."
    fi
}

# Run main function
main "$@"
