#!/bin/bash

# Ensure any fault stops script execution
set -e

# Check if the mas-cli exists and look up the latest release to install
# mas-cli recommends using brew, but the ansible playbook will install brew for us
if [ ! -f /usr/local/bin/mas ]; then
  echo "mas-cli was not found! Looking up latest version from Github releases"
  mas_latest_release=$(curl -s https://api.github.com/repos/mas-cli/mas/releases/latest | python -c "import sys, json; sys.stdout.write(json.load(sys.stdin)['assets'][1]['browser_download_url']);");
  echo "Downloading and installing mas-cli from Github"
  curl -sL $mas_latest_release -o mas.zip > /dev/null
  sudo unzip mas.zip -d /usr/local/bin/ > /dev/null
  rm mas.zip
fi

MAC_CONFIG_URL=https://codeload.github.com/blaet/mac-config/zip/master
MAC_CONFIG_DIR=/usr/local/MacConfig/

# Create MacConfig directory
if [ ! -d "${MAC_CONFIG_DIR}" ]; then
  echo "Creating MacConfig directory"
  sudo mkdir -p "${MAC_CONFIG_DIR}"
fi

# Download MacConfig files
echo "Downloading MacConfig files"
curl -sL $MAC_CONFIG_URL -o mac-config.zip > /dev/null
sudo unzip mac-config.zip -d "${MAC_CONFIG_DIR}" > /dev/null
rm mac-config.zip

echo "Bootstrapping complete"
