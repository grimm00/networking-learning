#!/bin/bash

# Start a bash session with the 'run' command pre-loaded

echo "Starting bash session with 'run' command available..."
echo "Type 'exit' to return to host system"
echo ""

# Ensure the init script is sourced
if [ -f /scripts/init-run.sh ]; then
    source /scripts/init-run.sh
    echo "✅ 'run' command loaded successfully!"
else
    echo "Warning: /scripts/init-run.sh not found"
fi

# Start interactive bash with the run command available
exec bash --rcfile <(echo "source /scripts/init-run.sh; PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\[\033[00m\]\$ '")
