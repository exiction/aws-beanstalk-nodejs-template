#!/bin/bash

# Log the process for debugging purposes
echo "Moving .htpasswd file to /etc/nginx/conf.d/"

# Ensure the destination directory exists
mkdir -p /etc/nginx/conf.d

# Move the .htpasswd file from the deployment package to the correct location
if [ -f /var/app/current/.platform/nginx/conf.d/htpasswd ]; then
    sudo cp /var/app/current/.platform/nginx/conf.d/htpasswd /etc/nginx/conf.d/.htpasswd # move file to the default nginx configuration +rename
    echo ".htpasswd file moved successfully."

    # Restart nginx to apply the changes
    sudo systemctl restart nginx

else
    echo ".htpasswd file not found in the deployment package."
    exit 1
fi
