#!/bin/bash

# List of packages to install
packages=(
    asusctl
    supergfxctl
    rog-control-center
    telegram-desktop-bin
    google-chrome
    bitwarden
    docker
    docker-compose
    openrazer-daemon
    openrazer-driver-dkms
    openrazer-meta
    python-openrazer
    polychromatic
    ttf-meslo-nerd
    # heroic-games-launcher-bin
    lutris
	thunderbird
    gnome-keyring
    visual-studio-code-bin
#     hyprlock
#     swayidle
#     curseforge
)

# Create a file to store selected packages
output_file="selected_packages.txt"
> "$output_file" # Clear the file if it exists

echo "Select packages to install:"
for package in "${packages[@]}"; do
    read -p "Do you want to install $package? (y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "$package" >> "$output_file"
    fi
done

echo "The list of selected packages has been saved to $output_file."
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

yay -Rsu pokemon-colorscripts-git

sudo pacman -Rsu code
# Add "password-store": "gnome" to ~/.vscode/argv.json
vscode_argv_file="$HOME/.vscode/argv.json"
if [[ -f "$vscode_argv_file" ]]; then
    if ! grep -q '"password-store": "gnome"' "$vscode_argv_file"; then
        echo "Adding 'password-store': 'gnome' to $vscode_argv_file..."
        jq '. + {"password-store": "gnome"}' "$vscode_argv_file" > "${vscode_argv_file}.tmp" && mv "${vscode_argv_file}.tmp" "$vscode_argv_file"
        echo "'password-store': 'gnome' added successfully."
    else
        echo "'password-store': 'gnome' already exists in $vscode_argv_file."
    fi
else
    echo "Creating $vscode_argv_file and adding 'password-store': 'gnome'..."
    mkdir -p "$(dirname "$vscode_argv_file")"
    echo '{"password-store": "gnome"}' > "$vscode_argv_file"
    echo "$vscode_argv_file created and configured successfully."
fi
cp -r "${scrDir}/Configs/my/Candy/" /usr/share/sddm/themes/Candy/
# cp -r "${scrDir}/Configs/my/.zshrc" /home/malkir/

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


sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

# Configure git global settings
echo "Configuring git global settings..."
git config --global user.name "malkir23"
git config --global user.email "mandragorand@gmail.com"
git config --global core.editor "code --wait"
echo "Git global settings configured: name='malkir23', email='mandragorand@gmail.com'."

# Generate SSH key if it doesn't exist
ssh_key="$HOME/.ssh/id_rsa"
if [[ ! -f "$ssh_key" ]]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -C "mandragorand@gmail.com"
    echo "SSH key generated successfully."
else
    echo "SSH key already exists."
fi

# Display the SSH public key
echo "Your SSH public key is:"
cat "${ssh_key}.pub"

openrazer-daemon -Fv
echo "Installation process completed!"
