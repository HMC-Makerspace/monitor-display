#!/bin/bash

# Setup file for Raspberry Pi

# Enable console-based auto-login
sudo raspi-config do_boot_behaviour B2


# Install FBI, the frame buffer interface, used for showing photos
sudo apt-get install fbi


# from https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# write out current crontab
crontab -l > mycron
# Install a cron to restart FBI on reboot
echo "@reboot sleep 20; cd Pictures && sudo killall fbi && sudo fbi --noverbose -a -t 20 -T 1 *.jpg" >> mycron
#install new cron file
crontab mycron
rm mycron


# Download one sample jpg
curl -sSL -o "$HOME/Pictures/Makerspace.jpg" https://raw.githubusercontent.com/HMC-Makerspace/monitor-display/refs/heads/main/Makerspace.jpg


# Reboot to update configuration
sudo reboot
