#!/bin/bash

# Initialize the 'run' command and autocomplete
# This script should be sourced in your shell

# Define the run function
run() {
    /scripts/run-script.sh "$@"
}

# Autocomplete function for 'run' command
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

echo "✅ 'run' command and autocomplete initialized!"
echo "Usage: run <script-name> [arguments...]"
echo "Try: run help"
echo "Autocomplete enabled - press Tab after 'run '"
