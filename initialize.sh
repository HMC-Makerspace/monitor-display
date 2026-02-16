#!/bin/bash

if [ -z $1 ]; then
    echo "No ip address provided. Please run $0 <ip> with the ip of your Raspberry Pi"
    exit 0;
fi

if ! [ -f rclone.conf ]; then
    echo "rclone.conf not found. Please configure rclone for Google Drive and put the config file in this folder"
    exit 0;
fi

ip=$1

ssh-copy-id makerspace@$ip

scp setup.sh makerspace@$ip:~/
ssh -t makerspace@$ip "mkdir -p ~/.config/rclone"
scp rclone.conf makerspace@$ip:~/.config/rclone/

ssh -t makerspace@$ip "~/setup.sh"
