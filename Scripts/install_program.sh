#!/bin/bash

# Check if yay is installed
if ! command -v yay > /dev/null; then
    echo "yay is not installed. Please install it before running this script."
    exit 1
fi

# Read the list of selected packages
input_file="selected_packages.txt"

if [[ ! -f "$input_file" ]]; then
    echo "The file $input_file does not exist. Run 'ask_install.sh' first."
    exit 1
fi

# Install the packages
while IFS= read -r package; do
    if yay -Qs "$package" > /dev/null; then
        echo "$package is already installed."
    else
        echo "Installing $package..."
        yay -S --noconfirm "$package"
    fi
done < "$input_file"

echo "All selected packages have been installed!"
