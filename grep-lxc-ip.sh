#!/bin/bash
set -euo pipefail

# Script Description: Fetch IPs of running LXC containers from multiple Proxmox hosts
# Author: elvee
# Version: 0.1.0
# License: MIT
# Creation Date: 17-11-2023
# Last Modified: 17-11-2023

# Default Constants
OUTPUT_FILE="$HOME/lxc_ips_output.txt"
SUBNET_PREFIX="192"  # Match only IPs starting with this prefix
PROXMOX_HOSTS=("192.168.x.x" "192.168.x.x" "192.168.x.x" "192.168.x.x")  # Proxmox host IPs

# Display help message
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Fetch IPs of running LXC containers from multiple Proxmox hosts."
  echo "Ensure passwordless SSH is configured to avoid interruptions."
  echo ""
  echo "Options:"
  echo "  -o, --output-file FILE       Override the default output file (default: $OUTPUT_FILE)"
  echo "  -s, --subnet-prefix PREFIX   Override the default subnet prefix for IP filtering (default: $SUBNET_PREFIX)"
  echo "  -ip, --proxmox-ip IP         Add a Proxmox host IP to the list of hosts"
  echo "  -h, --help                   Show this help message"
  echo ""
  echo "Output:"
  echo "  Saves results in the specified output file."
}

# Centralized error handling
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Parse command-line arguments
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -o|--output-file)
        OUTPUT_FILE="$2"
        shift 2
        ;;
      -s|--subnet-prefix)
        SUBNET_PREFIX="$2"
        shift 2
        ;;
      -ip|--proxmox-ip)
        PROXMOX_HOSTS+=("$2")
        shift 2
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        error_exit "Unknown argument: $1"
        ;;
    esac
  done
}

# Fetch VMIDs of running containers from a Proxmox host
fetch_vmids() {
  local host=$1
  ssh root@"$host" "pct list" 2>/dev/null || error_exit "Failed to connect to $host" |
    awk 'NR>1 && $2=="running" {print $1}'
}

# Fetch and filter IPs for a given VMID on a specific Proxmox host
fetch_ip() {
  local host=$1
  local vmid=$2
  local ip
  ip=$(ssh root@"$host" "lxc-info -n \"$vmid\" -iH" 2>/dev/null || echo "N/A")

  # Filter IPs based on subnet prefix
  while IFS= read -r line; do
    if [[ $line == $SUBNET_PREFIX* ]]; then
      echo "$line"
      return
    fi
  done <<< "$ip"

  echo "N/A"
}

# Fetch LXC data from all Proxmox hosts
fetch_lxc_data() {
  > "$OUTPUT_FILE"  # Clear the output file

  for host in "${PROXMOX_HOSTS[@]}"; do
    echo "Fetching data from Proxmox host: $host"
    local vmids
    vmids=$(fetch_vmids "$host")

    for vmid in $vmids; do
      local ip
      ip=$(fetch_ip "$host" "$vmid")
      echo -e "$vmid\t$ip" >> "$OUTPUT_FILE"
    done
  done
}

# Display results in a formatted table
display_results() {
  echo "Results:"
  printf "%-8s %-15s\n" "VMID" "IP"
  echo "-------------------------"
  while IFS=$'\t' read -r vmid ip; do
    printf "%-8s %-15s\n" "$vmid" "$ip"
  done < "$OUTPUT_FILE"
}

# Main function to coordinate the script
main() {
  parse_arguments "$@"

  echo "Starting LXC IP fetch from multiple Proxmox hosts..."
  fetch_lxc_data
  display_results
  echo "Process completed. Results saved in $OUTPUT_FILE."
}

main "$@"