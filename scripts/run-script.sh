#!/bin/bash

# Dynamic Script Runner
# Automatically detects and runs .sh or .py files from /scripts/ directory

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Dynamic Script Runner${NC}"
    echo ""
    echo "Usage: run <script-name> [arguments...]"
    echo ""
    echo "Examples:"
    echo "  run dns-analyzer google.com"
    echo "  run ssh-troubleshoot -a localhost"
    echo "  run http-analyzer -v https://google.com"
    echo ""
    echo "Available scripts:"
    echo -e "${GREEN}Python scripts:${NC}"
    ls /scripts/*.py 2>/dev/null | sed 's|/scripts/||' | sed 's|\.py||' | sed 's/^/  /'
    echo ""
    echo -e "${GREEN}Shell scripts:${NC}"
    ls /scripts/*.sh 2>/dev/null | sed 's|/scripts/||' | sed 's|\.sh||' | sed 's/^/  /'
}

# Function to run a script
run_script() {
    local script_name="$1"
    shift  # Remove first argument, rest become script arguments
    
    # Check if script name is provided
    if [ -z "$script_name" ]; then
        echo -e "${RED}❌ No script name provided${NC}"
        show_usage
        return 1
    fi
    
    # Check for help
    if [ "$script_name" = "help" ] || [ "$script_name" = "-h" ] || [ "$script_name" = "--help" ]; then
        show_usage
        return 0
    fi
    
    # Check for list command
    if [ "$script_name" = "list" ] || [ "$script_name" = "ls" ]; then
        echo -e "${BLUE}Available scripts in /scripts/:${NC}"
        echo ""
        echo -e "${GREEN}Python scripts:${NC}"
        ls /scripts/*.py 2>/dev/null | sed 's|/scripts/||' | sed 's|\.py||' | sed 's/^/  /'
        echo ""
        echo -e "${GREEN}Shell scripts:${NC}"
        ls /scripts/*.sh 2>/dev/null | sed 's|/scripts/||' | sed 's/^/  /'
        return 0
    fi
    
    # Try to find the script
    local script_path=""
    local script_type=""
    
    # Check for Python script
    if [ -f "/scripts/${script_name}.py" ]; then
        script_path="/scripts/${script_name}.py"
        script_type="python"
    # Check for shell script
    elif [ -f "/scripts/${script_name}.sh" ]; then
        script_path="/scripts/${script_name}.sh"
        script_type="shell"
    # Check if full path with extension is provided
    elif [ -f "/scripts/${script_name}" ]; then
        script_path="/scripts/${script_name}"
        if [[ "$script_name" == *.py ]]; then
            script_type="python"
        elif [[ "$script_name" == *.sh ]]; then
            script_type="shell"
        else
            # Try to determine by file content
            if head -1 "$script_path" | grep -q "#!/usr/bin/env python\|#!/usr/bin/python\|import "; then
                script_type="python"
            elif head -1 "$script_path" | grep -q "#!/bin/bash\|#!/bin/sh"; then
                script_type="shell"
            else
                echo -e "${RED}❌ Cannot determine script type for: $script_name${NC}"
                return 1
            fi
        fi
    else
        echo -e "${RED}❌ Script not found: $script_name${NC}"
        echo ""
        echo -e "${YELLOW}Available scripts:${NC}"
        show_usage
        return 1
    fi
    
    # Run the script
    echo -e "${BLUE}🚀 Running $script_type script: $script_path${NC}"
    echo -e "${YELLOW}Arguments: $*${NC}"
    echo ""
    
    if [ "$script_type" = "python" ]; then
        python3 "$script_path" "$@"
    elif [ "$script_type" = "shell" ]; then
        bash "$script_path" "$@"
    fi
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Script completed successfully${NC}"
    else
        echo ""
        echo -e "${RED}❌ Script failed with exit code: $exit_code${NC}"
    fi
    
    return $exit_code
}

# Main function
main() {
    # If no arguments, show usage
    if [ $# -eq 0 ]; then
        show_usage
        return 0
    fi
    
    # Run the script
    run_script "$@"
}

# Run main function with all arguments
main "$@"
