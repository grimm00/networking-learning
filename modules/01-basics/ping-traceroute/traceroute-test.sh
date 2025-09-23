#!/bin/bash

# Comprehensive traceroute testing script
# Usage: ./traceroute-test.sh [target]

TARGET=${1:-"8.8.8.8"}
LOG_FILE="traceroute_results_$(date +%Y%m%d_%H%M%S).log"

echo "=== Traceroute Testing Script ==="
echo "Target: $TARGET"
echo "Log file: $LOG_FILE"
echo "Started: $(date)"
echo ""

# Function to run traceroute test
run_traceroute_test() {
    local description="$1"
    local command="$2"
    
    echo "--- $description ---"
    echo "Command: $command"
    echo "Time: $(date)"
    echo ""
    
    eval "$command" | tee -a "$LOG_FILE"
    echo ""
    echo "--- End of $description ---"
    echo ""
}

# Test 1: Basic traceroute
run_traceroute_test "Basic Traceroute" "traceroute $TARGET"

# Test 2: Different traceroute methods
run_traceroute_test "ICMP Traceroute" "traceroute -I $TARGET"
run_traceroute_test "UDP Traceroute" "traceroute -U $TARGET"
run_traceroute_test "TCP Traceroute" "traceroute -T $TARGET"

# Test 3: Different destinations
DESTINATIONS=("8.8.8.8" "1.1.1.1" "google.com" "github.com" "stackoverflow.com")

for dest in "${DESTINATIONS[@]}"; do
    run_traceroute_test "Traceroute to $dest" "traceroute $dest"
done

# Test 4: Multiple runs to same destination (check for path changes)
echo "--- Multiple Runs to Same Destination ---"
for i in {1..3}; do
    run_traceroute_test "Run $i to $TARGET" "traceroute $TARGET"
done

echo ""
echo "=== Traceroute Testing Complete ==="
echo "Results saved to: $LOG_FILE"
echo "Ended: $(date)"
