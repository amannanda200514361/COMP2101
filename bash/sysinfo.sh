#!/bin/bash

# Display fully-qualified domain name
fqdn=$(hostname)
echo "Fully-Qualified Domain Name (FQDN): $fqdn"

# Display operating system name and version
os_info=$(hostnamectl)
echo "Operating System: $os_info"

# Display IP addresses (excluding 127.0.0.1)
ip_addresses=$(hostname -I | grep -v '^127')
echo "IP Addresses: $ip_addresses"

# Display available space in the root filesystem
root_space=$(df -h / | awk 'NR==2 {print $4}')
echo "Available Space in Root Filesystem: $root_space"
