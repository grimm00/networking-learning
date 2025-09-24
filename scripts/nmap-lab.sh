#!/bin/bash

# Nmap Lab Script
# Interactive learning environment for nmap network scanning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "\n${GREEN}Step $1: $2${NC}"
    echo -e "${CYAN}$3${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
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

# Check if nmap is available
check_nmap() {
    if ! command -v nmap >/dev/null 2>&1; then
        print_error "Nmap is not installed or not in PATH"
        print_info "Install nmap with: apt-get install nmap"
        exit 1
    fi
    
    print_success "Nmap is available"
    nmap --version | head -1
}

# Get target from user
get_target() {
    echo -e "\n${CYAN}Enter target for scanning:${NC}"
    echo "Examples:"
    echo "  - Single host: 192.168.1.1"
    echo "  - Network range: 192.168.1.0/24"
    echo "  - Hostname: google.com"
    echo "  - Multiple hosts: 192.168.1.1,192.168.1.2"
    echo ""
    read -p "Target: " TARGET
    
    if [ -z "$TARGET" ]; then
        print_error "Target cannot be empty"
        exit 1
    fi
    
    print_success "Target set to: $TARGET"
}

# Host discovery lab
host_discovery_lab() {
    print_header "HOST DISCOVERY LAB"
    
    print_step "1" "Ping Scan (Host Discovery Only)" \
        "Discovers active hosts without port scanning"
    
    print_info "Running: nmap -sn $TARGET"
    echo ""
    nmap -sn "$TARGET"
    
    print_step "2" "ARP Ping Scan (Local Networks)" \
        "Uses ARP requests for local network discovery"
    
    print_info "Running: nmap -PR $TARGET"
    echo ""
    nmap -PR "$TARGET"
    
    print_step "3" "TCP SYN Ping" \
        "Uses TCP SYN packets for host discovery"
    
    print_info "Running: nmap -PS $TARGET"
    echo ""
    nmap -PS "$TARGET"
    
    print_step "4" "UDP Ping" \
        "Uses UDP packets for host discovery"
    
    print_info "Running: nmap -PU $TARGET"
    echo ""
    nmap -PU "$TARGET"
    
    print_step "5" "ICMP Ping" \
        "Uses ICMP echo requests for host discovery"
    
    print_info "Running: nmap -PE $TARGET"
    echo ""
    nmap -PE "$TARGET"
}

# Port scanning lab
port_scanning_lab() {
    print_header "PORT SCANNING LAB"
    
    print_step "1" "TCP SYN Scan (Default)" \
        "Fast, stealthy scan that doesn't complete TCP handshake"
    
    print_info "Running: nmap -sS $TARGET"
    echo ""
    nmap -sS "$TARGET"
    
    print_step "2" "TCP Connect Scan" \
        "Completes full TCP handshake, more detectable"
    
    print_info "Running: nmap -sT $TARGET"
    echo ""
    nmap -sT "$TARGET"
    
    print_step "3" "UDP Scan" \
        "Scans UDP ports (slower but necessary for UDP services)"
    
    print_info "Running: nmap -sU $TARGET"
    echo ""
    nmap -sU "$TARGET"
    
    print_step "4" "Top Ports Scan" \
        "Scans the most common ports"
    
    print_info "Running: nmap --top-ports 1000 $TARGET"
    echo ""
    nmap --top-ports 1000 "$TARGET"
    
    print_step "5" "Specific Ports Scan" \
        "Scans only specified ports"
    
    print_info "Running: nmap -p 22,80,443 $TARGET"
    echo ""
    nmap -p 22,80,443 "$TARGET"
}

# Service detection lab
service_detection_lab() {
    print_header "SERVICE DETECTION LAB"
    
    print_step "1" "Service Detection" \
        "Identifies services running on open ports"
    
    print_info "Running: nmap -sV $TARGET"
    echo ""
    nmap -sV "$TARGET"
    
    print_step "2" "Aggressive Service Detection" \
        "Comprehensive service detection with OS detection"
    
    print_info "Running: nmap -A $TARGET"
    echo ""
    nmap -A "$TARGET"
    
    print_step "3" "Version Detection with Intensity" \
        "Controls how hard nmap tries to detect versions"
    
    print_info "Running: nmap -sV --version-intensity 9 $TARGET"
    echo ""
    nmap -sV --version-intensity 9 "$TARGET"
    
    print_step "4" "Light Version Detection" \
        "Quick version detection with minimal probes"
    
    print_info "Running: nmap -sV --version-intensity 0 $TARGET"
    echo ""
    nmap -sV --version-intensity 0 "$TARGET"
}

# OS detection lab
os_detection_lab() {
    print_header "OS DETECTION LAB"
    
    print_step "1" "OS Detection" \
        "Attempts to identify the operating system"
    
    print_info "Running: nmap -O $TARGET"
    echo ""
    nmap -O "$TARGET"
    
    print_step "2" "OS Detection with Guessing" \
        "Includes OS guesses when exact match not found"
    
    print_info "Running: nmap -O --osscan-guess $TARGET"
    echo ""
    nmap -O --osscan-guess "$TARGET"
    
    print_step "3" "Aggressive OS Detection" \
        "Combines OS detection with service detection"
    
    print_info "Running: nmap -A $TARGET"
    echo ""
    nmap -A "$TARGET"
}

# NSE scripts lab
nse_scripts_lab() {
    print_header "NSE SCRIPTS LAB"
    
    print_step "1" "Safe Scripts" \
        "Runs scripts that are unlikely to cause problems"
    
    print_info "Running: nmap --script safe $TARGET"
    echo ""
    nmap --script safe "$TARGET"
    
    print_step "2" "Discovery Scripts" \
        "Scripts that gather information about the target"
    
    print_info "Running: nmap --script discovery $TARGET"
    echo ""
    nmap --script discovery "$TARGET"
    
    print_step "3" "Vulnerability Scripts" \
        "Scripts that check for known vulnerabilities"
    
    print_info "Running: nmap --script vuln $TARGET"
    echo ""
    nmap --script vuln "$TARGET"
    
    print_step "4" "SSL/TLS Scripts" \
        "Scripts for SSL/TLS analysis"
    
    print_info "Running: nmap --script ssl-enum-ciphers -p 443 $TARGET"
    echo ""
    nmap --script ssl-enum-ciphers -p 443 "$TARGET"
    
    print_step "5" "HTTP Scripts" \
        "Scripts for web server analysis"
    
    print_info "Running: nmap --script http-enum $TARGET"
    echo ""
    nmap --script http-enum "$TARGET"
}

# Advanced techniques lab
advanced_techniques_lab() {
    print_header "ADVANCED TECHNIQUES LAB"
    
    print_step "1" "Timing Templates" \
        "Different timing templates for speed vs stealth"
    
    print_info "Running: nmap -T0 $TARGET (Paranoid - slowest)"
    echo ""
    nmap -T0 "$TARGET"
    
    print_info "Running: nmap -T5 $TARGET (Insane - fastest)"
    echo ""
    nmap -T5 "$TARGET"
    
    print_step "2" "Packet Fragmentation" \
        "Fragments packets to evade firewalls"
    
    print_info "Running: nmap -f $TARGET"
    echo ""
    nmap -f "$TARGET"
    
    print_step "3" "Decoy Scans" \
        "Uses decoy IPs to hide the real source"
    
    print_info "Running: nmap -D decoy1,decoy2,ME $TARGET"
    echo ""
    nmap -D decoy1,decoy2,ME "$TARGET"
    
    print_step "4" "Source Port Spoofing" \
        "Uses different source ports"
    
    print_info "Running: nmap --source-port 53 $TARGET"
    echo ""
    nmap --source-port 53 "$TARGET"
    
    print_step "5" "Firewall Evasion Scans" \
        "Different scan types to bypass firewalls"
    
    print_info "Running: nmap -sA $TARGET (ACK scan)"
    echo ""
    nmap -sA "$TARGET"
    
    print_info "Running: nmap -sF $TARGET (FIN scan)"
    echo ""
    nmap -sF "$TARGET"
}

# Output formats lab
output_formats_lab() {
    print_header "OUTPUT FORMATS LAB"
    
    print_step "1" "Normal Output" \
        "Default human-readable output"
    
    print_info "Running: nmap $TARGET"
    echo ""
    nmap "$TARGET"
    
    print_step "2" "Verbose Output" \
        "More detailed information"
    
    print_info "Running: nmap -v $TARGET"
    echo ""
    nmap -v "$TARGET"
    
    print_step "3" "XML Output" \
        "Machine-readable XML format"
    
    print_info "Running: nmap -oX nmap_output.xml $TARGET"
    echo ""
    nmap -oX nmap_output.xml "$TARGET"
    
    print_info "XML output saved to: nmap_output.xml"
    
    print_step "4" "Grepable Output" \
        "Easy to parse with grep"
    
    print_info "Running: nmap -oG nmap_output.grep $TARGET"
    echo ""
    nmap -oG nmap_output.grep "$TARGET"
    
    print_info "Grepable output saved to: nmap_output.grep"
    
    print_step "5" "All Formats" \
        "Saves output in all formats"
    
    print_info "Running: nmap -oA nmap_results $TARGET"
    echo ""
    nmap -oA nmap_results "$TARGET"
    
    print_info "All formats saved with prefix: nmap_results"
}

# Interactive menu
show_menu() {
    echo -e "\n${PURPLE}NMAP LAB MENU${NC}"
    echo "=============="
    echo "1. Host Discovery Lab"
    echo "2. Port Scanning Lab"
    echo "3. Service Detection Lab"
    echo "4. OS Detection Lab"
    echo "5. NSE Scripts Lab"
    echo "6. Advanced Techniques Lab"
    echo "7. Output Formats Lab"
    echo "8. Run All Labs"
    echo "9. Custom Scan"
    echo "0. Exit"
    echo ""
}

# Custom scan function
custom_scan() {
    print_header "CUSTOM SCAN"
    
    echo -e "${CYAN}Enter custom nmap command (without target):${NC}"
    echo "Examples:"
    echo "  -sS -p 80,443"
    echo "  -A -T4"
    echo "  --script vuln"
    echo "  -sU -p 53,67,123"
    echo ""
    read -p "Command: " CUSTOM_CMD
    
    if [ -z "$CUSTOM_CMD" ]; then
        print_error "Command cannot be empty"
        return
    fi
    
    print_info "Running: nmap $CUSTOM_CMD $TARGET"
    echo ""
    nmap $CUSTOM_CMD "$TARGET"
}

# Run all labs
run_all_labs() {
    print_header "RUNNING ALL LABS"
    
    host_discovery_lab
    port_scanning_lab
    service_detection_lab
    os_detection_lab
    nse_scripts_lab
    advanced_techniques_lab
    output_formats_lab
    
    print_success "All labs completed!"
}

# Main function
main() {
    print_header "NMAP LEARNING LAB"
    print_info "Interactive nmap scanning exercises"
    print_warning "Only scan networks you own or have permission to scan!"
    
    # Check prerequisites
    check_nmap
    get_target
    
    # Main loop
    while true; do
        show_menu
        read -p "Select option (0-9): " choice
        
        case $choice in
            1) host_discovery_lab ;;
            2) port_scanning_lab ;;
            3) service_detection_lab ;;
            4) os_detection_lab ;;
            5) nse_scripts_lab ;;
            6) advanced_techniques_lab ;;
            7) output_formats_lab ;;
            8) run_all_labs ;;
            9) custom_scan ;;
            0) 
                print_success "Exiting nmap lab"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
