#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root."
   exit 1
fi

# List available disks
echo "Available disks:"
disks=($(lsblk -d -e 7,11 -o NAME -n))
for i in "${!disks[@]}"; do
    echo "$((i+1)). ${disks[i]}"
done

# User selects a disk
echo ""
read -p "Enter the number of the disk you want to use: " disk_number
selected_disk="/dev/${disks[$((disk_number-1))]}"

# Safety check
echo "Selected disk: $selected_disk"
read -p "Are you sure you want to proceed with $selected_disk? This can lead to data loss. (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Start partitioning with cfdisk
echo "Starting cfdisk for $selected_disk"
cfdisk $selected_disk

# Format the first partition as FAT32
echo "Formatting the first partition as FAT32..."
mkfs.fat -F32 "${selected_disk}1"

# LUKS Formatting the second partition
echo "Formatting the second partition with LUKS..."
cryptsetup

