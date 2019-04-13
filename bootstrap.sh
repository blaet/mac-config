#!/bin/bash

# Ensure any fault stops script execution
set -ex

# This will get our current console user regardless of whether the script if run with sudo or not
logged_in_user=$(python -c "import SystemConfiguration, sys; sys.stdout.write(SystemConfiguration.SCDynamicStoreCopyConsoleUser(None, None, None)[0]);")

# Blanket sudo line
sudo_blanket_file="/etc/sudoers.d/mac-config-blanket"
sudo_blanket_contents="${logged_in_user} ALL= (ALL) NOPASSWD: ALL"

# Enable blanket passwordless sudo rights for logged in user
function enable_blanket_sudo_rights () {
  echo "SETUP - Enabling blanket sudo rights"
  echo "$sudo_blanket_contents" | sudo tee "$sudo_blanket_file" > /dev/null
}

# Revoke blanket sudo rights
function revoke_blanket_sudo_rights () {
  echo "CLEANUP - Revoking blanket sudo right"
  sudo rm -rf "$sudo_blanket_file"
}

# Remove possible temp files
function remove_temp_files () {
  echo "CLEANUP - Removing temp files"
  rm -rf "mas*"
  rm -rf "mac-config*"
}

# Cleanup when script exists (unexpectedly)
function cleanup () {
  remove_temp_files
  revoke_blanket_sudo_rights
}
trap cleanup EXIT

# Enable sudo rights
enable_blanket_sudo_rights

# Check if the mas-cli exists and look up the latest release to install
# mas-cli recommends using brew, but the ansible playbook will install brew for us
if [ ! -f /usr/local/bin/mas ]; then
  echo "mas-cli was not found! Looking up latest version from Github releases"
  mas_latest_release=$(curl -s https://api.github.com/repos/mas-cli/mas/releases/latest | python -c "import sys, json; sys.stdout.write(json.load(sys.stdin)['assets'][0]['browser_download_url']);");
  if [ ! -f mas.zip ]; then
    echo "Downloading and installing mas-cli from Github"
    curl -sL "$mas_latest_release" -o mas.pkg > /dev/null
  fi
  sudo mkdir -p /usr/local/bin
  sudo installer -pkg mas.pkg -target /
  rm -rf "mas*"
fi

MAC_CONFIG_URL=https://codeload.github.com/blaet/mac-config/zip/master
MAC_CONFIG_DIR=/usr/local/MacConfig

# Create MacConfig directory
if [ ! -d "${MAC_CONFIG_DIR}" ]; then
  echo "Creating MacConfig directory"
  sudo mkdir -p "${MAC_CONFIG_DIR}"
fi

# Download MacConfig files
echo "Downloading MacConfig files"
curl -sL $MAC_CONFIG_URL -o mac-config.zip > /dev/null
unzip -o mac-config.zip > /dev/null
sudo cp -r mac-config-master/* "${MAC_CONFIG_DIR}/"
rm -rf "mac-config*"

# Run run.sh
echo "Executing run.sh"
bash "${MAC_CONFIG_DIR}/run.sh"

echo "Bootstrapping complete"
