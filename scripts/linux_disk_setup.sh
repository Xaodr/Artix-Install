#!/bin/bash

# ANSI-Farbencodes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Keine Farbe

# Überprüfung, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}Dieses Skript muss als Root ausgeführt werden.${NC}"
   exit 1
fi

# Auflistung der verfügbaren Festplatten
echo -e "${GREEN}Verfügbare Festplatten:${NC}"
disks=($(lsblk -d -e 7,11 -o NAME -n))
for i in "${!disks[@]}"; do
    echo -e "${GREEN}$((i+1)). ${disks[i]}${NC}"
done

# Benutzer wählt eine Festplatte aus
echo ""
read -p "Geben Sie die Nummer der zu verwendenden Festplatte ein: " disk_number
selected_disk="/dev/${disks[$((disk_number-1))]}"

# Partitionspräfix festlegen (unterschiedlich für NVMe und andere)
partition_prefix=""
if [[ $selected_disk == *"nvme"* ]]; then
    partition_prefix="p"
fi

# Sicherheitsüberprüfung
echo -e "${RED}Ausgewählte Festplatte: $selected_disk${NC}"
read -p "Sind Sie sicher, dass Sie mit $selected_disk fortfahren möchten? Dies kann zum Datenverlust führen. (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Bildschirm löschen
clear

# Automatische Partitionierung mit fdisk
echo -e "${GREEN}Partitionierung von $selected_disk${NC}"
{
   echo y # Automatisch mit Ja antworten, um vorhandene Signaturen zu entfernen
   echo g # Erstellen einer neuen GPT-Partitionstabelle
   echo n # Neue Partition (EFI)
   echo 1 # Partition Nummer 1
   echo   # Standard - Beginn am Anfang der Festplatte
   echo +1G # 1 GB EFI-Partition
   echo t # Typ der Partition ändern
   echo 1 # EFI-System
   echo n # Neue Partition (Linux-Dateisystem)
   echo 2 # Partition Nummer 2
   echo   # Standard - Start unmittelbar nach der vorherigen Partition
   echo   # Standard - Partition bis zum Ende der Festplatte ausdehnen
   echo w # Schreiben der Partitionstabelle und Beenden
} | fdisk $selected_disk

# Partitionsnamen für die Formatierung festlegen
efi_partition="${selected_disk}${partition_prefix}1"
linux_partition="${selected_disk}${partition_prefix}2"

# EFI-Partition als FAT32 formatieren
echo -e "${GREEN}Formatierung der EFI-Partition als FAT32...${NC}"
mkfs.fat -F32 $efi_partition

# Formatieren der Linux-Partition als ext4
echo -e "${GREEN}Formatierung der Linux-Partition als ext4...${NC}"
mkfs.ext4 $linux_partition

# Die Partitionen sind jetzt bereit zur Verwendung
echo -e "${GREEN}Partitionierung und Formatierung abgeschlossen.${NC}"
