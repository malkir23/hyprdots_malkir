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


# Ask if the user wants to remove dunst
read -p "Do you want to remove dunst? (y/n): " remove_dunst
if [[ "$remove_dunst" =~ ^[Yy]$ ]]; then
    echo "Removing dunst..."
    sudo pacman -Rns dunst
    echo "Installing swaync..."
    sudo pacman -S swaync
    echo "Copying swaync configuration files..."
    cp -r "${scrDir}/Configs/my/swaync/" ~/.config/
    echo "Configuration files copied to ~/.config/swaync."
fi

# Configure git global settings
echo "Configuring git global settings..."
git config --global user.name "malkir23"
git config --global user.email "mandragorand@gmail.com"
echo "Git global settings configured: name='malkir23', email='mandragorand@gmail.com'."

# Generate SSH key if it doesn't exist
ssh_key="$HOME/.ssh/id_rsa"
if [[ ! -f "$ssh_key" ]]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_key" -N ""
    echo "SSH key generated successfully."
else
    echo "SSH key already exists."
fi

# Display the SSH public key
echo "Your SSH public key is:"
cat "${ssh_key}.pub"

openrazer-daemon -Fv
echo "Installation process completed!"
