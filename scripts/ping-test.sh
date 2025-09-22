#!/bin/bash

# Comprehensive ping testing script
# Usage: ./ping-test.sh [target]

TARGET=${1:-"8.8.8.8"}
LOG_FILE="ping_results_$(date +%Y%m%d_%H%M%S).log"

echo "=== Ping Testing Script ==="
echo "Target: $TARGET"
echo "Log file: $LOG_FILE"
echo "Started: $(date)"
echo ""

# Function to run ping test
run_ping_test() {
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

# Test 1: Basic connectivity
run_ping_test "Basic Connectivity Test" "ping -c 4 $TARGET"

# Test 2: Different packet sizes
for size in 32 64 128 256 512 1024 1500; do
    run_ping_test "Packet Size Test ($size bytes)" "ping -c 4 -s $size $TARGET"
done

# Test 3: Different intervals
for interval in 0.1 0.5 1 2; do
    run_ping_test "Interval Test ($interval seconds)" "ping -c 10 -i $interval $TARGET"
done

# Test 4: Long-term monitoring
echo "Starting 5-minute continuous ping test..."
echo "Press Ctrl+C to stop"
ping -i 1 $TARGET | tee -a "$LOG_FILE"

echo ""
echo "=== Ping Testing Complete ==="
echo "Results saved to: $LOG_FILE"
echo "Ended: $(date)"
