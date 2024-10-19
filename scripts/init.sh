#!/bin/bash

# Function to print error and exit
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Ensure the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
    error_exit "Please run this script as root."
fi

echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

echo "Replacing /etc/ssh/sshd_config with the latest version..."
wget -qO /etc/ssh/sshd_config https://raw.githubusercontent.com/fractalcounty/dokehouse/main/config/sshd_config || error_exit "Failed to download the new sshd_config."

echo "Setting proper permissions for /etc/ssh/sshd_config..."
chmod 600 /etc/ssh/sshd_config || error_exit "Failed to set permissions for /etc/ssh/sshd_config."

echo "Ensuring ~/.ssh directory exists..."
mkdir -p ~/.ssh || error_exit "Failed to create ~/.ssh directory."

echo "Setting proper permissions for ~/.ssh/authorized_keys..."
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys || error_exit "Failed to set permissions for ~/.ssh/authorized_keys."

read -p "Would you like to set a public SSH key? (y/n): " set_key

if [ "$set_key" == "y" ]; then
    read -p "Please paste your public SSH key: " pubkey

    echo "Setting the provided key as the only key in ~/.ssh/authorized_keys..."
    
    echo "$pubkey" > ~/.ssh/authorized_keys || error_exit "Failed to set ~/.ssh/authorized_keys."
    echo "SSH key has been set successfully."
else
    echo "No changes made to SSH keys."
fi

read -p "Would you like to restart the SSH service now? (y/n): " restart_ssh
if [ "$restart_ssh" == "y" ]; then
    echo "Restarting ssh service..."
    systemctl restart ssh || error_exit "Failed to restart ssh service."
    echo "SSH service restarted successfully."
    systemctl restart sshd || error_exit "Failed to restart sshd service."
    echo "SSHD service restarted successfully."
else
    echo "Please remember to restart SSH services later to apply changes."
fi

echo "Script completed successfully."
