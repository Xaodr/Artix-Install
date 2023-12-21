#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 
   exit 1
fi

# Dictionary of required programs
declare -A required_programs=(
    [curl]="not installed"
    [unzip]="not installed"
)

# Function to check if the programs are installed
check_and_install_programs() {
    for program in "${!required_programs[@]}"; do
        if ! command -v $program &> /dev/null; then
            echo "$program is not installed."
            read -p "Do you want to install $program? (y/n) " answer
            if [[ $answer =~ ^[Yy]$ ]]; then
                pacman -Syu --needed $program
                required_programs[$program]="installed"
            else
                echo "$program is required to proceed. Exiting."
                exit 1
            fi
        else
            required_programs[$program]="installed"
        fi
    done
}

# Check and install required programs
check_and_install_programs

# Create a directory in /tmp
installer_directory="/tmp/artix_installer"
mkdir -p "$installer_directory"
cd "$installer_directory"

# Download the file
curl -o DisplayLink_Ubuntu.zip "https://www.synaptics.com/sites/default/files/exe_files/2023-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.8-EXE.zip"

# Set the environment variable
export SYSTEMINITDAEMON="runit"

# Unzip and run the installer
unzip DisplayLink_Ubuntu.zip
chmod +x *.run
./displaylink-driver-*.run

# Clean up
cd
rm -rf "$installer_directory"

echo "Installation completed."

