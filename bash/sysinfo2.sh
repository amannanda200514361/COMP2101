#!/bin/bash

#Displayin g the hostname only
hostname=$(hostname)

# Display fully-qualified domain name
fqdn=$(hostname --fqdn)


# Display operating system name and version only
os_info=$(lsb_release -ds)


# Display IP addresses when sending or receiving data 
ip_addresses=$(ip route get 1 | awk '{print $7}')


# Display available space in the root filesystem
root_space=$(df -h / | awk 'NR==2 {print $4}')

# Output template
output_template=$(cat << EOT

-------------------------------------------------------
Hostname: $hostname
Fully Qualified Domain Name: $fqdn
Operating System: $os_info
IP Address: $ip_addresses
Root Filesystem Space: $root_space

EOT
)

# Print the formatted output
echo -e "$output_template"

