#!/bin/bash

# Setup script to enable the 'run' command in the container

echo "Setting up 'run' command in container..."

# Add the init script to bashrc
docker exec net-practice bash -c "echo 'source /scripts/init-run.sh' >> ~/.bashrc"

echo "✅ Setup complete!"
echo ""
echo "To use the 'run' command:"
echo "1. Enter the container: docker exec -it net-practice bash"
echo "2. The 'run' command will be automatically available"
echo "3. Try: run help"
echo "4. Try: run list"
echo "5. Try: run dns-analyzer google.com"
echo ""
echo "Features:"
echo "✅ Auto-detects .py and .sh files"
echo "✅ Tab completion enabled"
echo "✅ Passes all arguments to scripts"
echo "✅ Colored output and error handling"
echo ""
echo "Examples:"
echo "  run dns-analyzer google.com"
echo "  run ssh-troubleshoot -a localhost"
echo "  run http-analyzer -v https://google.com"
echo "  run help"
echo "  run list"
