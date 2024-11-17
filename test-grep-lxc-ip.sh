#!/bin/bash
set -euo pipefail

# Script Description: Test script to verify core functionality of the LXC IP retrieval script
# Author: elvee
# Version: 0.1.0
# License: MIT
# Creation Date: 17-11-2023
# Last Modified: 17-11-2023

# Constants
OUTPUT_FILE="test_lxc_output.txt"
SUBNET_PREFIX="192"  # Match only IPs starting with this prefix

# Function to fetch VMIDs of running containers from `pct list`
test_fetch_vmid() {
  # Fetch running containers and exclude header
  pct list | awk 'NR>1 && $2=="running" {print $1}'
}

# Function to fetch and filter IPs for a given VMID
test_fetch_ip() {
  local vmid=$1
  local ip
  ip=$(lxc-info -n "$vmid" -iH 2>/dev/null || echo "N/A")

  # Check if the IP matches the subnet prefix
  while IFS= read -r line; do
    if [[ $line == $SUBNET_PREFIX* ]]; then
      echo "$line"
      return
    fi
  done <<< "$ip"

  # Return N/A if no IP matches the prefix
  echo "N/A"
}

# Function to test the main script logic
test_core_functionality() {
  # Prepare output file
  > "$OUTPUT_FILE"

  # Fetch running VMIDs
  local vmids
  vmids=$(test_fetch_vmid)

  # Process each VMID
  for vmid in $vmids; do
    # Fetch the first matching IP for the container
    local ip
    ip=$(test_fetch_ip "$vmid")
    echo -e "$vmid\t$ip" >> "$OUTPUT_FILE"
  done

  # Display results in a formatted table
  echo "Test Results:"
  printf "%-8s %-15s\n" "VMID" "IP"
  echo "-------------------------"
  while IFS=$'\t' read -r vmid ip; do
    printf "%-8s %-15s\n" "$vmid" "$ip"
  done < "$OUTPUT_FILE"
}

# Main function for the test script
main() {
  echo "Starting LXC script core functionality test on a single Proxmox host..."
  test_core_functionality
  echo "Test completed. Results saved in $OUTPUT_FILE."
}

main