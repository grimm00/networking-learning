#!/bin/bash

# Version management script for Networking Learning Project
# Handles version updates across all files

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Get current version
get_current_version() {
    if [ -f "VERSION" ]; then
        cat VERSION
    else
        echo "0.0.0"
    fi
}

# Validate version format (semantic versioning)
validate_version() {
    local version="$1"
    if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?(\+[a-zA-Z0-9]+)?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Update version in VERSION file
update_version_file() {
    local new_version="$1"
    echo "$new_version" > VERSION
    print_success "Updated VERSION file to $new_version"
}

# Update version in package.json
update_package_json() {
    local new_version="$1"
    if [ -f "package.json" ]; then
        # Use sed to update version in package.json
        sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$new_version\"/" package.json
        rm package.json.bak
        print_success "Updated package.json version to $new_version"
    else
        print_warning "package.json not found"
    fi
}

# Update version in Python files
update_python_files() {
    local new_version="$1"
    
    # Find Python files with version strings
    find scripts/ -name "*.py" -exec grep -l "__version__" {} \; | while read -r file; do
        if [ -f "$file" ]; then
            sed -i.bak "s/__version__ = \"[^\"]*\"/__version__ = \"$new_version\"/" "$file"
            rm "$file.bak"
            print_success "Updated $file version to $new_version"
        fi
    done
}

# Update version in shell scripts
update_shell_files() {
    local new_version="$1"
    
    # Find shell files with version strings
    find . -name "*.sh" -exec grep -l "VERSION=" {} \; | while read -r file; do
        if [ -f "$file" ]; then
            sed -i.bak "s/VERSION=\"[^\"]*\"/VERSION=\"$new_version\"/" "$file"
            rm "$file.bak"
            print_success "Updated $file version to $new_version"
        fi
    done
}

# Update version in README files
update_readme_files() {
    local new_version="$1"
    
    # Update main README.md
    if [ -f "README.md" ]; then
        sed -i.bak "s/version [0-9]\+\.[0-9]\+\.[0-9]\+/version $new_version/g" README.md
        rm README.md.bak
        print_success "Updated README.md version references to $new_version"
    fi
}

# Update CHANGELOG.md
update_changelog() {
    local new_version="$1"
    local date=$(date +%Y-%m-%d)
    
    if [ -f "CHANGELOG.md" ]; then
        # Create temporary file with new changelog entry
        cat > CHANGELOG.tmp << EOF
# Changelog

All notable changes to the Networking Learning Project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Version management system
- Automated version updates across all files

## [$new_version] - $date

### Added
- Initial release with comprehensive networking learning tools
- Cross-platform installation and setup
- Containerized learning environment
- Educational modules and documentation

EOF
        
        # Append existing changelog content (skip first 3 lines)
        tail -n +4 CHANGELOG.md >> CHANGELOG.tmp
        
        # Replace original changelog
        mv CHANGELOG.tmp CHANGELOG.md
        
        print_success "Updated CHANGELOG.md with version $new_version"
    else
        print_warning "CHANGELOG.md not found"
    fi
}

# Create git tag
create_git_tag() {
    local new_version="$1"
    local tag_name="v$new_version"
    
    if git tag -l | grep -q "^$tag_name$"; then
        print_warning "Tag $tag_name already exists"
        return 1
    fi
    
    git tag -a "$tag_name" -m "Release version $new_version"
    print_success "Created git tag $tag_name"
}

# Show version information
show_version_info() {
    local version="$1"
    print_header "Version Information"
    
    echo "Current version: $version"
    echo "Version type: $(get_version_type "$version")"
    echo "Next version: $(get_next_version "$version")"
    echo ""
    echo "Files that will be updated:"
    echo "  - VERSION"
    echo "  - package.json"
    echo "  - Python files with __version__"
    echo "  - Shell scripts with VERSION="
    echo "  - README.md"
    echo "  - CHANGELOG.md"
}

# Get version type (major, minor, patch)
get_version_type() {
    local version="$1"
    if [[ $version =~ ^[0-9]+\.0\.0$ ]]; then
        echo "major"
    elif [[ $version =~ ^[0-9]+\.[0-9]+\.0$ ]]; then
        echo "minor"
    else
        echo "patch"
    fi
}

# Get next version (increment patch)
get_next_version() {
    local version="$1"
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3)
    
    patch=$((patch + 1))
    echo "$major.$minor.$patch"
}

# Show help
show_help() {
    echo "Version Management Script for Networking Learning Project"
    echo ""
    echo "Usage: $0 [COMMAND] [VERSION]"
    echo ""
    echo "Commands:"
    echo "  show                    Show current version information"
    echo "  update <version>        Update version across all files"
    echo "  patch                   Increment patch version"
    echo "  minor                   Increment minor version"
    echo "  major                   Increment major version"
    echo "  tag <version>           Create git tag for version"
    echo "  release <version>       Update version and create tag"
    echo "  help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 show                 # Show current version"
    echo "  $0 update 1.1.0         # Update to version 1.1.0"
    echo "  $0 patch                # Increment patch version"
    echo "  $0 release 1.2.0        # Update version and create tag"
    echo ""
    echo "Version format: MAJOR.MINOR.PATCH (semantic versioning)"
}

# Main function
main() {
    local command="$1"
    local version="$2"
    
    case "$command" in
        "show")
            local current_version=$(get_current_version)
            show_version_info "$current_version"
            ;;
        "update")
            if [ -z "$version" ]; then
                print_error "Version required for update command"
                exit 1
            fi
            
            if ! validate_version "$version"; then
                print_error "Invalid version format: $version"
                print_error "Use semantic versioning: MAJOR.MINOR.PATCH"
                exit 1
            fi
            
            print_header "Updating Version to $version"
            update_version_file "$version"
            update_package_json "$version"
            update_python_files "$version"
            update_shell_files "$version"
            update_readme_files "$version"
            update_changelog "$version"
            print_success "Version updated to $version"
            ;;
        "patch"|"minor"|"major")
            local current_version=$(get_current_version)
            local major=$(echo "$current_version" | cut -d. -f1)
            local minor=$(echo "$current_version" | cut -d. -f2)
            local patch=$(echo "$current_version" | cut -d. -f3)
            
            case "$command" in
                "patch")
                    patch=$((patch + 1))
                    ;;
                "minor")
                    minor=$((minor + 1))
                    patch=0
                    ;;
                "major")
                    major=$((major + 1))
                    minor=0
                    patch=0
                    ;;
            esac
            
            local new_version="$major.$minor.$patch"
            print_header "Incrementing $command version to $new_version"
            update_version_file "$new_version"
            update_package_json "$new_version"
            update_python_files "$new_version"
            update_shell_files "$new_version"
            update_readme_files "$new_version"
            update_changelog "$new_version"
            print_success "Version incremented to $new_version"
            ;;
        "tag")
            if [ -z "$version" ]; then
                print_error "Version required for tag command"
                exit 1
            fi
            
            create_git_tag "$version"
            ;;
        "release")
            if [ -z "$version" ]; then
                print_error "Version required for release command"
                exit 1
            fi
            
            if ! validate_version "$version"; then
                print_error "Invalid version format: $version"
                exit 1
            fi
            
            print_header "Creating Release $version"
            update_version_file "$version"
            update_package_json "$version"
            update_python_files "$version"
            update_shell_files "$version"
            update_readme_files "$version"
            update_changelog "$version"
            create_git_tag "$version"
            print_success "Release $version created"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
