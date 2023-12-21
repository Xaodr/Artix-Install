#!/bin/bash

# Define required tools
required_tools=("wget" "unzip")

# Check if all required tools are installed
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Tool $tool is not installed."
        exit 1
    fi
done

# Define target directory
target_directory="/usr/share/jetbrains-mono-nerd"

# Create target directory if it does not exist
if [ ! -d "$target_directory" ]; then
    mkdir -p "$target_directory"
fi

# URL of the file to download
font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"

# Download and extract the font
wget "$font_url" -O /tmp/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d "$target_directory"

# Clean up
rm /tmp/JetBrainsMono.zip

echo "Installation completed."
