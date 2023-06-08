#!/bin/bash

# Check if the user has root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root privileges." >&2
    exit 1
fi

# System Description Section
echo "System Description"
echo "------------------"

# Computer manufacturer
computer_manufacturer=$(dmidecode -s system-manufacturer 2>/dev/null)
if [[ -n $computer_manufacturer ]]; then
    echo "Computer manufacturer: $computer_manufacturer"
else
    echo "Computer manufacturer: Not available"
fi

# Computer description or model
computer_model=$(dmidecode -s system-product-name 2>/dev/null)
if [[ -n $computer_model ]]; then
    echo "Computer model: $computer_model"
else
    echo "Computer model: Not available"
fi

# Computer serial number
computer_serial=$(dmidecode -s system-serial-number 2>/dev/null)
if [[ -n $computer_serial ]]; then
    echo "Computer serial number: $computer_serial"
else
    echo "Computer serial number: Not available"
fi

echo

# CPU Information Section
echo "CPU Information"
echo "---------------"

# CPU manufacturer and model
cpu_info=$(lshw -class processor 2>/dev/null)
cpu_manufacturer=$(echo "$cpu_info" | awk -F ': ' '/vendor/ {print $2}' | head -n 1)
cpu_model=$(echo "$cpu_info" | awk -F ': ' '/product/ {print $2}' | head -n 1)
if [[ -n $cpu_manufacturer && -n $cpu_model ]]; then
    echo "CPU manufacturer: $cpu_manufacturer"
    echo "CPU model: $cpu_model"
else
    echo "CPU information: Not available"
fi

# CPU architecture
cpu_arch=$(lscpu | awk -F ': +' '/Architecture/ {print $2}')
if [[ -n $cpu_arch ]]; then
    echo "CPU architecture: $cpu_arch"
fi

# CPU core count
cpu_cores=$(lscpu | awk -F ': +' '/^CPU\(s\)/ {print $2}')
if [[ -n $cpu_cores ]]; then
    echo "CPU core count: $cpu_cores"
fi

# CPU maximum speed
cpu_max_speed=$(lscpu | awk -F ': +' '/^CPU max MHz/ {print $2}')
if [[ -n $cpu_max_speed ]]; then
    cpu_max_speed_human=$(echo "scale=2; $cpu_max_speed / 1000" | bc)
    echo "CPU maximum speed: ${cpu_max_speed_human} GHz"
else
    echo "CPU maximum speed: Not available"
fi

# CPU cache sizes
cpu_caches=$(lscpu | awk -F ': +' '/^L[1-3] cache/ {print $2}')
if [[ -n $cpu_caches ]]; then
    echo "CPU cache sizes:"
    echo "$cpu_caches"
else
    echo "CPU cache sizes: Not available"
fi

echo

# Operating System Information Section
echo "Operating System Information"
echo "---------------------------"

# Linux distro
linux_distro=$(lsb_release -si 2>/dev/null)
if [[ -n $linux_distro ]]; then
    echo "Linux distro: $linux_distro"
fi

# Distro version
distro_version=$(lsb_release -sr 2>/dev/null)
if [[ -n $distro_version ]]; then
    echo "Distro version: $distro_version"
fi
