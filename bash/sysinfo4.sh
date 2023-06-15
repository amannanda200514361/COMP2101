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


# RAM Storage Information Section

# Function to check command success
check_command() {
  if [ $? -ne 0 ]; then
    echo "Error executing command: $1" >&2
    exit 1
  fi
}

# RAM section
echo "RAM Information"
echo "-----------------------"

# Run lshw command and save output in a variable
ram_info=$(lshw -short -C memory)

# Check if RAM data is available
if [ -z "$ram_info" ]; then
  echo "RAM data is unavailable."
else
  # Print table header
  printf "%-20s %-20s %-15s %-15s %-20s\n" "Manufacturer" "Model" "Size" "Speed" "Location"

  # Extract relevant RAM information
  while IFS= read -r line; do
    manufacturer=$(echo "$line" | awk '{print $2}')
    model=$(echo "$line" | awk '{print $3}')
    size=$(echo "$line" | awk '{print $4}')
    speed=$(echo "$line" | awk '{print $5}')
    location=$(echo "$line" | awk '{print $6}')

    # Print RAM component information
    printf "%-20s %-20s %-15s %-15s %-20s\n" "$manufacturer" "$model" "$size" "$speed" "$location"
  done <<< "$ram_info"

  # Get RAM information using free command
  ram_info=$(free -h)

  # Check if RAM information is available
  if [[ -z $ram_info ]]; then
      echo "Error: No RAM information available"
      exit 1
  fi

  # Print RAM section title
  echo "RAM Information"
  echo "----------------"

  # Extract total installed RAM size
  total_ram_size=$(echo "$ram_info" | awk '/^Mem:/ {print $2}')

  # Check if total RAM size is available
  if [[ -z $total_ram_size ]]; then
      echo "Error: Failed to retrieve total installed RAM size"
      exit 1
  fi

  # Print total installed RAM size
  echo "Total Installed RAM: $total_ram_size"


fi

# Function to display an error message and exit
show_error() {
  echo "Error: $1"
  exit 1
}

# Function to check if a command executed successfully
check_command() {
  if [ "$?" -ne 0 ]; then
    show_error "Failed to execute command: $1"
  fi
}

# Disk storage section
echo "Disk Storage"
echo "-------------------------"

# Get disk drive information using lsblk command
disk_info=$(lsblk -o NAME,MODEL,SIZE,MOUNTPOINT,FSTYPE,FSSIZE,FSUSED -e 7,11)
check_command "lsblk command"

# Check if disk information is available
if [ -z "$disk_info" ]; then
  echo "No disk drive information available."
else
  # Parse disk information and display in a table format
  printf "%-20s %-20s %-15s %-15s %-20s %-20s %-20s\n" "Device" "Model" "Size" "Partition" "Mount Point" "Filesystem Size" "Free Space"
  echo "------------------------------------------------------------------------------------------------------------------------"

  # Extract disk drive information
  while IFS= read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    model=$(echo "$line" | awk '{print $2}')
    size=$(echo "$line" | awk '{print $3}')
    partition=$(echo "$line" | awk '{print $4}')
    mount_point=$(echo "$line" | awk '{print $5}')
    filesystem_size=$(echo "$line" | awk '{print $6}')
    free_space=$(echo "$line" | awk '{print $7}')

    # Remove suffix from size values
    size=$(echo "$size" | sed 's/[A-Za-z]*//g')
    filesystem_size=$(echo "$filesystem_size" | sed 's/[A-Za-z]*//g')
    free_space=$(echo "$free_space" | sed 's/[A-Za-z]*//g')

    printf "%-20s %-20s %-15s %-15s %-20s %-20s %-20s\n" "$device" "$model" "$size" "$partition" "$mount_point" "$filesystem_size" "$free_space"
  done <<< "$disk_info"
fi

echo
echo "End of report."
