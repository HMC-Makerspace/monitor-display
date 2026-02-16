#!/bin/bash

# Setup file for Raspberry Pi

# Enable console-based auto-login
sudo raspi-config nonint do_boot_behaviour B2

sudo apt-get update

# Install FBI, the frame buffer interface, used for showing photos, and rclone for syncing
sudo apt-get -y install fbi rclone imagemagick ghostscript

# Make the Pictures folder if it doesn't exist
mkdir -p "$HOME/Pictures"



### Create sync.sh
cat > "$HOME/Pictures/sync.sh" <<'EOF'

# Define locations
PHOTO_FOLDER=~/Pictures/monitor/photos
TEMP_FOLDER=~/Pictures/monitor/temp
SYNC_FOLDER=~/Pictures/monitor/sync
SYM_FOLDER=~/Pictures/monitor/sym
DRIVE_FOLDER="3 - Graphics/Monitor Presentations/Active Monitor Presentation"
DIFF_FILE=~/Pictures/monitor/diff.txt
MOD_FILE=~/Pictures/monitor/mod.txt
MISSING_FILE=~/Pictures/monitor/miss.txt

# Create locations if they don't exist
mkdir -p "$PHOTO_FOLDER/"
mkdir -p "$TEMP_FOLDER/"
mkdir -p "$SYNC_FOLDER/"
mkdir -p "$SYM_FOLDER/"
touch $DIFF_FILE $MOD_FILE $MISSING_FILE

# Check if there are any files that differ between the source (drive) and dest (sync folder)
rclone check "drive:$DRIVE_FOLDER" "$SYNC_FOLDER" --one-way --differ "$MOD_FILE" --missing-on-dst "$MISSING_FILE" > /dev/null
cat "$MOD_FILE" "$MISSING_FILE" > "$DIFF_FILE"
if [[ -s "$DIFF_FILE" ]]; then
        # There are differences! resync
        rclone sync "drive:$DRIVE_FOLDER" "$SYNC_FOLDER"
        # Convert pdf to jpg
        find "$SYNC_FOLDER" -type f -name "*.pdf" -exec echo "Converting {}" \; -exec magick -density 144 -quality 90 "{}" "$TEMP_FOLDER/photo-%1d.jpg" \;
        # Move all photos to photo folder
        mv -fv $TEMP_FOLDER/* $PHOTO_FOLDER/
        # Count photos
        count=$(ls -1 "$PHOTO_FOLDER" | wc -l)
        echo Linking files...
        # Recreate all symlinks
        for i in {0..99} # up to 100 photos allowed
        do
                mod_i=$((i % count))
                ln -sf "$PHOTO_FOLDER/photo-$mod_i.jpg" "$SYM_FOLDER/photo-$i.jpg" > /dev/null
        done
fi
EOF




# Define the sync cron job for every 10 minutes
NEW_CRON_JOB="*/10 * * * * ~/Pictures/sync.sh"

# Check if the cron job already exists to prevent duplication
if ! crontab -l | grep -qF -- "$NEW_CRON_JOB"; then
    # If the cron job doesn't exist, add it
    (crontab -l 2>/dev/null; echo "$NEW_CRON_JOB") | crontab -
    echo "Cron job added successfully."
else
    echo "Cron job already exists, no changes made."
fi


# Add fbi runner to .bashrc if it doesn't already exist
if ! grep -qF "/sym/*" ~/.bashrc ; then
 
    cat >> ~/.bashrc <<'EOF'
if [[ -z $SSH_CONNECTION ]]; then
        fbi --noverbose -a -T 1 -t 20 --cachemem 0 /home/makerspace/Pictures/monitor/sym/*
fi
EOF

fi


# Run sync.sh to create intial files
chmod +x "$HOME/Pictures/sync.sh"
"$HOME/Pictures/sync.sh"

echo Setup complete!

# Reboot to update configuration and begin fbi
sudo reboot
