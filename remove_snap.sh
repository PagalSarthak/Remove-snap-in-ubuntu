#!/bin/bash
echo

# Function to prompt for user confirmation
prompt_confirmation() {
    while true; do
        read -p "$1 [y/n]: " choice
        case "$choice" in
            y|Y ) return 0;; # Yes
            n|N ) echo "Operation aborted."; exit 1;; # No
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Prompt for confirmation to proceed with the removal
prompt_confirmation "This script will remove Snap packages and the Snapd service and install Firefox for you. Do you want to continue?"

# Check if Snapd is installed
if command_exists snap; then
    echo "Removing snap packages..."
    sudo snap remove firefox || handle_error "Failed to remove snap package: firefox"
    sudo snap remove gtk-common-themes || handle_error "Failed to remove snap package: gtk-common-themes"
    sudo snap remove gnome-42-2204 || handle_error "Failed to remove snap package: gnome-42-2204"
    sudo snap remove snapd-desktop-integration || handle_error "Failed to remove snap package: snapd-desktop-integration"
    sudo snap remove snap-store || handle_error "Failed to remove snap package: snap-store"
    sudo snap remove firmware-updater || handle_error "Failed to remove snap package: firmware-updater"
    sudo snap remove bare || handle_error "Failed to remove snap package: bare"
    sudo snap remove core22 || handle_error "Failed to remove snap package: core22"
    sudo snap remove snapd || handle_error "Failed to remove snap package: snapd"

    echo "Stopping and disabling snapd service..."
    sudo systemctl stop snapd || handle_error "Failed to stop snapd service"
    sudo systemctl disable snapd || handle_error "Failed to disable snapd service"
    sudo systemctl mask snapd || handle_error "Failed to mask snapd service"
    
    # Purge snapd package
    echo "Purging snapd package..."
    sudo apt purge snapd -y || handle_error "Failed to purge snapd package"

    # Mark snapd package on hold
    echo "Marking snapd package on hold..."
    sudo apt-mark hold snapd || handle_error "Failed to mark snapd package on hold"

    # Remove snap directories
    echo "Removing snap directories..."
    sudo rm -rf ~/snap
    sudo rm -rf /snap
    sudo rm -rf /var/snap
    sudo rm -rf /var/lib/snapd

    echo "Snap packages and snapd have been removed."
else
    echo "Snap is not installed. Skipping Snap removal steps."
fi

echo "Creating preference file to prevent Snap from being reinstalled..."
echo "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null || handle_error "Failed to create preference file to prevent Snap reinstallation"

# Prompt for confirmation to install Firefox
prompt_confirmation "Do you want to add Mozilla's APT repository and install Firefox?"

# Add Mozilla’s APT repository and install Firefox
echo "Adding Mozilla's APT repository and installing Firefox..."
sudo install -d -m 0755 /etc/apt/keyrings || handle_error "Failed to create keyrings directory"
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null || handle_error "Failed to download Mozilla signing key"
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null || handle_error "Failed to add Mozilla APT repository"
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla || handle_error "Failed to set APT preferences for Mozilla packages"
sudo apt-get update && sudo apt-get install firefox || handle_error "Failed to install Firefox"

echo "Snap packages and snapd have been removed. Firefox has been installed from Mozilla's APT repository."

# Prompt for confirmation to install Gnome App Store
prompt_confirmation "Do you want to install Gnome App Store?"

# Install Gnome App Store
echo "Adding Gnome App store...."
sudo apt install --install-suggests gnome-software || handle_error "Failed to install Gnome App Store"

echo "Enjoy your Snap-less Ubuntu"
