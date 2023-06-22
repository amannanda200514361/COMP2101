#!/bin/bash

function cpureport {
    # CPU Report
    cat <<EOF
CPU Report
----------
CPU manufacturer and model: $(uname -p)
CPU architecture: $(uname -m)
CPU core count: $(nproc)
CPU maximum speed: $(lscpu | awk '/^CPU MHz/ { printf "%.2f GHz\n", $3/1000 }')
Cache sizes:
$(lscpu | awk -F ': +' '/^L[1-3] cache/ {print $2}')

EOF
}

function computerreport {
    # Computer Report
    if [[ $(id -u) -eq 0 ]]; then
        cat <<EOF
Computer Report
---------------
Computer manufacturer: $(dmidecode -s system-manufacturer)
Computer description or model: $(dmidecode -s system-product-name)
Computer serial number: $(dmidecode -s system-serial-number)

EOF
    else
        errormessage "Root access is required to retrieve computer information."
    fi
}


function osreport {
    # OS Report
    cat <<EOF
OS Report
---------
Linux distro: $(lsb_release -sd)
Distro version: $(lsb_release -sr)

EOF
}

function ramreport {
    # RAM Report
    cat <<EOF
RAM Report
----------
Installed Memory Components:

$(dmidecode -t memory | awk '/^Memory Device$/ { count++ } /^Size:|^Speed:|^Manufacturer:|^Part Number:|^Locator:/ {ORS=(NR%5?FS:RS)}; NR%5==0 { print count, $2, $4, $6, $8, $10 }' | while read -r count size speed manufacturer part_number locator; do
    printf "Device%-5s %-15s %-15s %-20s %-25s %s\n" "$count:" "$manufacturer" "$part_number" "$size" "$speed" "$locator"
done)

Total size of installed RAM: $(free -h | awk '/^Mem:/ { print $2 }')

EOF
}



function videoreport {
    # Video Report
    cat <<EOF
Video Report
------------
Video card/chipset manufacturer: $(lspci | awk '/VGA compatible controller:/ { print $5 }')
Video card/chipset description or model: $(lspci -vnnn | awk -F': ' '/VGA compatible controller/ { print $2 }')

EOF
}

function diskreport {
    # Disk Report
    cat <<EOF
Disk Report
----------
Installed Disk Drives:

$(lsblk -o NAME,TYPE,SIZE,VENDOR,MODEL | awk '$2=="disk" { printf "%-15s %-15s %-20s %-15s %-10s\n", $1, $4, $5, "-", "-" }')
$(lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE,TYPE,FSSIZE,FSUSED | awk '$2!="" { printf "%-15s %-15s %-20s %-15s %-10s %-10s\n", $1, "-", "-", $4, $5, $6, $7 }')

EOF
}

function networkreport {
    # Network Report
    cat <<EOF
Network Report
--------------
Installed Network Interfaces:

$(ip -o link show | awk '{print $2,$9}' | sed 's/://g' | while read -r interface state; do
    manufacturer=$(ethtool -i "$interface" 2>/dev/null | awk '/^driver:/{print $2}')
    model=$(ethtool -i "$interface" 2>/dev/null | awk '/^bus-info:/{print $2}')
    speed=$(ethtool "$interface" 2>/dev/null | awk '/Speed:/{print $2}')
    ip_addresses=$(ip -o addr show dev "$interface" | awk '{print $4}')
    dns_servers=$(cat /etc/resolv.conf | awk '/^nameserver/{printf "%s ", $2}')
    search_domains=$(cat /etc/resolv.conf | awk '/^search/{print $2}')
    printf "%-15s %-25s %-15s %-15s %-30s %s\n" "$manufacturer" "$model" "$state" "$speed" "$ip_addresses" "$dns_servers $search_domains"
done)

EOF
}

function errormessage {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[Error - $timestamp]: $1" >&2
    echo "[Error - $timestamp]: $1" >> /var/log/systeminfo.log
}
