#!/bin/bash

# Function to retrieve the private IP address of the main interface
get_private_ip() {
    # Retrieving private IP address based on the platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # For macOS
        ip=$(ipconfig getifaddr en0)
    else
        # For Linux distributions
        ip=$(ip route get 1 | awk '{print $NF;exit}')
    fi

    echo "$ip"
}

# Function to convert IP address to sslip.io format
ip_to_sslip() {
    echo "$1" | tr '.' '-'
}

# Main script
private_ip=$(get_private_ip)

if [[ -n "$private_ip" ]]; then
    sslip_io=$(ip_to_sslip "$private_ip").sslip.io
    echo "{\"sslip_io\": \"$sslip_io\"}"
else
    echo "{\"error\": \"Failed to retrieve private IP address.\"}"
fi