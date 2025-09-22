#!/bin/bash

# Start a bash session with the 'run' command pre-loaded

echo "Starting bash session with 'run' command available..."
echo "Type 'exit' to return to host system"
echo ""

# Start bash with the init script sourced
exec bash -c "source /scripts/init-run.sh && exec bash"
