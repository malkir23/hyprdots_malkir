#!/bin/bash

# Check if yay is installed
if ! command -v yay > /dev/null; then
    echo "Error: 'yay' is not installed. Please install it before running this script."
    exit 1
fi

# File containing the list of selected packages
input_file="selected_packages.txt"

if [[ ! -f "$input_file" ]]; then
    echo "Error: The file '$input_file' does not exist. Run 'ask_install.sh' first."
    exit 1
fi

# Install the packages
while IFS= read -r package; do
    if [[ -n "$package" ]]; then  # Ensure the line is not empty
        if yay -Qs "$package" > /dev/null; then
            echo "$package is already installed."
        else
            echo "Installing $package..."
            if yay -S --noconfirm "$package"; then
                echo "$package installed successfully."
            else
                echo "Error: Failed to install $package."
            fi
        fi
    fi
done < "$input_file"

# Check if the 'plugdev' group exists
if ! getent group plugdev > /dev/null; then
    echo "Creating 'plugdev' group..."
    if sudo groupadd plugdev; then
        echo "'plugdev' group created successfully."
    else
        echo "Error: Failed to create 'plugdev' group."
        exit 1
    fi
else
    echo "'plugdev' group already exists."
fi

# Add the current user to the 'plugdev' group for OpenRazer
if ! groups | grep -qw plugdev; then
    echo "Adding the current user to the 'plugdev' group..."
    if command -v gpasswd > /dev/null; then
        sudo gpasswd -a "$USER" plugdev && echo "User '$USER' added to 'plugdev' group successfully." || echo "Failed to add user to 'plugdev' group."
    else
        echo "Error: 'gpasswd' command not found. Please install it before running this script."
    fi
else
    echo "User '$USER' is already in the 'plugdev' group."
fi

sudo pacman -S ttf-fira-code

openrazer-daemon -Fv
echo "Installation process completed!"
