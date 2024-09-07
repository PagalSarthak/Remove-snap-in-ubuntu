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

# Prompt for confirmation to proceed with the removal
prompt_confirmation "This script will remove Snap packages and the Snapd service and install FireFox for you. Do you want to continue?"

# Remove snap packages
echo "Removing snap packages..."
sudo snap remove firefox
sudo snap remove gtk-common-themes
sudo snap remove gnome-42-2204
sudo snap remove snapd-desktop-integration
sudo snap remove snap-store
sudo snap remove firmware-updater
sudo snap remove bare
sudo snap remove core22
sudo snap remove snapd

echo "Stopping and disabling snapd service..."
sudo systemctl stop snapd
sudo systemctl disable snapd
sudo systemctl mask snapd

# Purge snapd package
echo "Purging snapd package..."
sudo apt purge snapd -y

# Mark snapd package on hold
echo "Marking snapd package on hold..."
sudo apt-mark hold snapd

# Remove snap directories
echo "Removing snap directories..."
sudo rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd

echo "Snap packages and snapd have been removed."
echo "Creating preference file to prevent Snap from being reinstalled..."
echo "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null

# Prompt for confirmation to install Firefox
prompt_confirmation "Do you want to add Mozilla's APT repository and install Firefox?"

# Add Mozilla's APT repository and install Firefox
echo "Adding Mozilla's APT repository and installing Firefox..."
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt-get update && sudo apt-get install firefox

echo "Snap packages and snapd have been removed. Firefox has been installed from Mozilla's APT repository."

prompt_confirmation "Do you want to install Gnome App Store?"
echo "Adding Gnome App store...."
sudo apt install --install-suggests gnome-software
echo "enjoy your snap less ubuntu"