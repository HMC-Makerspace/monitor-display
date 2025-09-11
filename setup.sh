#!/bin/bash

# Setup file for Raspberry Pi

# Enable console-based auto-login
sudo raspi-config nonint do_boot_behaviour B2


# Install FBI, the frame buffer interface, used for showing photos
sudo apt-get -y install fbi at

# Define the fbi cron job
NEW_CRON_JOB="@reboot sleep 15; cd Pictures && sudo fbi --noverbose -a -t 20 -T 1 *.jpg"

# Check if the cron job already exists to prevent duplication
if ! crontab -l | grep -qF -- "$NEW_CRON_JOB"; then
    # If the cron job doesn't exist, add it
    (crontab -l 2>/dev/null; echo "$NEW_CRON_JOB") | crontab -
    echo "Cron job added successfully."
else
    echo "Cron job already exists, no changes made."
fi


# Download one sample jpg
curl -sSL https://raw.githubusercontent.com/HMC-Makerspace/monitor-display/refs/heads/main/Makerspace.jpg > "$HOME/Pictures/Makerspace.jpg"


# Reboot to update configuration
sudo reboot
