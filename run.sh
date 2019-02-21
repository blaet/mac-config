#!/bin/bash

# Ensure any fault stops script execution
set -e

if [ ! -d "/Applications/Xcode.app" ]; then
    echo "Xcode is not currently installed. We need Xcode for git and gcc"
    echo "Getting ready to install from the Mac App Store using mas-cli"
    signed_in=$([[ $(mas account) == *"Not signed in"* ]] && echo "No" || echo "Yes")
    if [ $signed_in == "No" ]; then
        echo "You are not currently signed in to the Mac App Store. Let's get you signed in!"
        read -p 'Apple ID Email: ' apple_id
        mas signin $apple_id
    fi
    bash scripts/mas_install.sh Xcode
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept
fi

# Newly setup computers often don't have pip install.
if [ ! -f /usr/local/bin/pip ]; then
    echo "Missing pip! Installing with easy_install"
    sudo easy_install pip
fi

# For now we need to specifically install ansible 2.7 since some of the tasks utilize features only in
# 2.2 and that is not the current version install by `pip installed ansible`
if [ ! -f /usr/local/bin/ansible ]; then
    echo "Installing Ansible 2.7"
    sudo pip install git+git://github.com/ansible/ansible.git@stable-2.7
fi

echo "Completed run.sh execution"