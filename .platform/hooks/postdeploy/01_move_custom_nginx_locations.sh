#!/bin/bash

# Log file for debugging purposes
LOGFILE="/var/log/eb-hooks.log"

# Source and destination directories
SOURCE_DIR="/var/app/current/.platform/nginx/conf.d/"
DEST_DIR="/etc/nginx/conf.d/elasticbeanstalk/"

# Log the process for debugging purposes
echo "Copying .conf files from $SOURCE_DIR to $DEST_DIR" | tee -a $LOGFILE

# Ensure the destination directory exists
mkdir -p $DEST_DIR

# Copy all .conf files from the source directory to the destination directory
for file in $SOURCE_DIR*.conf; do
    if [ -f "$file" ]; then
        sudo cp "$file" "$DEST_DIR"
    else
        echo "No .conf files found in $SOURCE_DIR" | tee -a $LOGFILE
        exit 1
    fi
done

echo "Copied all custom location files"

# Restart nginx to apply the changes
sudo systemctl restart nginx
echo "Nginx restarted successfully." | tee -a $LOGFILE
