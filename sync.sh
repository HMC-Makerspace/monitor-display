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

# Check if there are any files that differ between the source (drive) and dest (sync folder)
rclone check "drive:$DRIVE_FOLDER" "$SYNC_FOLDER" --one-way --differ "$MOD_FILE" --missing-on-dst "$MISSING_FILE"
cat "$MOD_FILE" "$MISSING_FILE" > "$DIFF_FILE"
if [[ -s "$DIFF_FILE" ]]; then
        # There are differences! resync
        rclone sync "drive:$DRIVE_FOLDER" "$SYNC_FOLDER"
        # Convert pdf to jpg
        find "$SYNC_FOLDER" -type f -name "*.pdf" -exec echo "{}" \; -exec magick -density 144 -quality 90 "{}" "$TEMP_FOLDER/photo-%1d.jpg" \;
        # Move all photos to photo folder
        mv -fv $TEMP_FOLDER/* $PHOTO_FOLDER/
        # Count photos
        count=$(ls -1 "$PHOTO_FOLDER" | wc -l)
        # Recreate all symlinks
        for i in {0..99} # up to 100 photos allowed
        do
                mod_i=$((i % count))
                ln -sf "$PHOTO_FOLDER/photo-$mod_i.jpg" "$SYM_FOLDER/photo-$i.jpg"
        done
fi
