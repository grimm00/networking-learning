#!/bin/bash

# Setup script for the 'run' alias and autocomplete

echo "Setting up 'run' alias and autocomplete..."

# Add the run function to bashrc
cat >> ~/.bashrc << 'EOF'

# Dynamic Script Runner Function
run() {
    /scripts/run-script.sh "$@"
}

# Autocomplete for 'run' command
_run_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # If this is the first argument after 'run'
    if [ ${COMP_CWORD} -eq 1 ]; then
        # Get all available scripts
        local scripts=()
        
        # Add Python scripts
        for script in /scripts/*.py; do
            [ -f "$script" ] && scripts+=($(basename "$script" .py))
        done
        
        # Add shell scripts
        for script in /scripts/*.sh; do
            [ -f "$script" ] && scripts+=($(basename "$script" .sh))
        done
        
        # Add special commands
        scripts+=("help" "list" "ls")
        
        # Filter based on current input
        COMPREPLY=( $(compgen -W "${scripts[*]}" -- "$cur") )
    else
        # For subsequent arguments, we could add script-specific completion
        # For now, just use default file completion
        COMPREPLY=()
    fi
}

# Register the completion function
complete -F _run_completion run

EOF

echo "✅ Alias and autocomplete setup complete!"
echo ""
echo "To use the new 'run' command:"
echo "1. Start a new bash session: bash"
echo "2. Or source the bashrc: source ~/.bashrc"
echo "3. Then use: run <script-name> [arguments...]"
echo ""
echo "Examples:"
echo "  run dns-analyzer google.com"
echo "  run ssh-troubleshoot -a localhost"
echo "  run help"
echo "  run list"
echo ""
echo "Autocomplete is enabled - try typing 'run ' and press Tab!"
