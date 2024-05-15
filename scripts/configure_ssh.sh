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

# Download and replace the sshd_config file
echo "Replacing /etc/ssh/sshd_config with the latest version..."
wget -qO /etc/ssh/sshd_config https://raw.githubusercontent.com/fractalcounty/OMAHOLE/main/config/sshd_config || error_exit "Failed to download the new sshd_config."

# Set proper permissions for sshd_config
echo "Setting proper permissions for /etc/ssh/sshd_config..."
chmod 600 /etc/ssh/sshd_config || error_exit "Failed to set permissions for /etc/ssh/sshd_config."

# Prompt the user for the public SSH key
read -p "Please paste your public SSH key: " pubkey

# Ensure the ~/.ssh directory exists
echo "Ensuring ~/.ssh directory exists..."
mkdir -p ~/.ssh || error_exit "Failed to create ~/.ssh directory."

# Replace the contents of the authorized_keys file with the new public key
echo "Updating ~/.ssh/authorized_keys with the provided key..."
echo "$pubkey" > ~/.ssh/authorized_keys || error_exit "Failed to write to ~/.ssh/authorized_keys."

# Set proper permissions for authorized_keys
echo "Setting proper permissions for ~/.ssh/authorized_keys..."
chmod 600 ~/.ssh/authorized_keys || error_exit "Failed to set permissions for ~/.ssh/authorized_keys."

# Prompt the user to restart the SSH service
read -p "Would you like to restart the SSH service now? (y/n): " restart_ssh
if [ "$restart_ssh" == "y" ]; then
    echo "Restarting ssh service..."
    systemctl restart ssh || error_exit "Failed to restart ssh service."
    echo "SSH service restarted successfully."
else
    echo "Please remember to restart the SSH service later to apply changes."
fi

echo "Script completed successfully."
