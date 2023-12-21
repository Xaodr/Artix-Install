#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if the script is running as root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root.${NC}"
   exit 1
fi

# List available disks
echo -e "${GREEN}Available disks:${NC}"
disks=($(lsblk -d -e 7,11 -o NAME -n))
for i in "${!disks[@]}"; do
    echo -e "${GREEN}$((i+1)). ${disks[i]}${NC}"
done

# User selects a disk
echo ""
read -p "Enter the number of the disk you want to use: " disk_number
selected_disk="/dev/${disks[$((disk_number-1))]}"

# Safety check
echo -e "${RED}Selected disk: $selected_disk${NC}"
read -p "Are you sure you want to proceed with $selected_disk? This can lead to data loss. (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Clear the screen
clear

# Start partitioning with cfdisk
echo -e "${GREEN}Starting cfdisk for $selected_disk${NC}"
cfdisk $selected_disk

# LUKS Formatting the second partition
echo -e "${GREEN}Formatting the second partition with LUKS...${NC}"
cryptsetup luksFormat "${selected_disk}2"

# Opening the LUKS partition
cryptsetup open "${selected_disk}2" alpha

# Format the first partition as FAT32
echo -e "${GREEN}Formatting the first partition as FAT32...${NC}"
mkfs.fat -F32 "${selected_disk}1"

# Format the opened LUKS partition as ext4
echo -e "${GREEN}Formatting the LUKS partition as ext4...${NC}"
mkfs.ext4 /dev/mapper/alpha

# Mount the root partition
mount /dev/mapper/alpha /mnt/

# Create and mount the boot directory
mkdir /mnt/boot
mount "${selected_disk}1" /mnt/boot

echo -e "${GREEN}Installation steps completed.${NC}"
