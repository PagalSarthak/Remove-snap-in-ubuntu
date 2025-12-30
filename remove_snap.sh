#!/bin/bash
echo "https://github.com/PagalSarthak/Remove-snap-in-ubuntu"
echo "thx for using our script"

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

# Function to prompt for user confirmation
prompt_confirmation() {
    while true; do
        read -p "$1 [y/n]: " choice
        case "$choice" in
            y|Y ) return 0;; # Yes
            n|N ) return 1;; # No
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to remove all Snap packages
remove_snap_packages() {
    echo "Removing all Snap packages..."
    # Get a list of all installed snap packages
    local packages
    packages=$(snap list | awk 'NR > 1 {print $1}')

    # Loop through the list and remove each package
    for snap_package in $packages; do
        echo "Removing $snap_package..."
        sudo snap remove "$snap_package" || true
        sleep 2  # Adding a short delay to ensure the package is removed
    done
}

# Function to remove Snapd service
remove_snapd() {
    echo "Stopping and disabling snapd service..."
    sudo systemctl stop snapd || true
    sudo systemctl disable snapd || true
    sudo systemctl mask snapd || true

    echo "Removing Snapd service..."
    sudo apt-get purge -y snapd || true
}


# Function to create a preference file to prevent Snap from being reinstalled
create_preference_file() {
    # check duplicated file
    if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
      sudo rm /etc/apt/preferences.d/nosnap.pref
    fi

    echo "Creating preference file to prevent Snap from being reinstalled..."
    echo "Package: snapd" | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin: release a=*" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
}

# Function to install Firefox from Mozilla's repository
install_firefox() {
    echo "Adding Mozilla's APT repository and installing Firefox..."
    sudo install -d -m 0755 /etc/apt/keyrings || handle_error "Failed to create keyrings directory"
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null || handle_error "Failed to download Mozilla signing key"
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null || handle_error "Failed to add Mozilla APT repository"
    echo "Package: *" | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    echo "Pin: origin packages.mozilla.org" | sudo tee -a /etc/apt/preferences.d/mozilla > /dev/null
    echo "Pin-Priority: 1000" | sudo tee -a /etc/apt/preferences.d/mozilla > /dev/null

    sudo apt-get -qq update

    IS_FFESR=1
    if prompt_confirmation "Do you want to install ESR Version?"; then
      IS_FFESR=0
      sudo apt-get install -qq -y firefox-esr || handle_error "Failed to install Firefox"
    else
      sudo apt-get install -qq -y firefox || handle_error "Failed to install Firefox"
    fi
}

# Function to install GNOME Software Center
install_gnome_software() {
    echo "Installing GNOME Software Center..."
    sudo apt install -qq -y gnome-software || handle_error "Failed to install GNOME Software Center"
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}


# Main script execution
echo "Starting Snap removal process..."

# First, remove snapd if it's installed
remove_snapd

# Remove all Snap packages
while snap list | awk 'NR > 1 {print $1}' | grep .; do
    remove_snap_packages
    echo "Waiting for Snap packages to be fully removed..."
    sleep 5
done

# Clean up Snap directories and create a preference file
create_preference_file

IS_FIREFOX=1
# Prompt for confirmation to install Firefox
if prompt_confirmation "Do you want to add Mozilla's APT repository and install Firefox?"; then
  IS_FIREFOX=0
  install_firefox
fi

IS_GNOME=1
# Prompt for confirmation to install GNOME Software Center
if prompt_confirmation "Do you want to install GNOME Software Center?"; then
  IS_GNOME=0
  install_gnome_software
fi

# report of removal and installation process
echo "========================================"
echo "  Snap removal process completed."

if [ "$IS_FIREFOX" -eq 0 ] || [ "$IS_GNOME" -eq 0 ]; then
  if [ "$IS_FIREFOX" -eq 0 ]; then
    if [ "$IS_FFESR" -eq 0 ]; then
      echo "    - Firefox ESR"
    else
      echo "    - Firefox"
    fi
  fi

  if [ "$IS_GNOME" -eq 0 ] ; then
    echo "    - GNOME Software Center"
  fi

  echo "  has been installed."
fi

echo "========================================"