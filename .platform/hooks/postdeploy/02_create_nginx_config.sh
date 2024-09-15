#!/bin/bash

# Log the process for debugging purposes
echo "Moving nginx.conf file to /etc/nginx/nginx.conf"

# Ensure the destination directory exists
mkdir -p /etc/nginx/

# Move the nginx.conf file from the deployment package to the correct location
if [ -f /var/app/current/.platform/nginx/nginx.conf ]; then
    sudo cp /var/app/current/.platform/nginx/nginx.conf /etc/nginx/nginx.conf # move file to the default nginx configuration
    echo "nginx.conf file moved successfully."

    # Restart nginx to apply the changes
    sudo systemctl restart nginx

else
    echo "nginx.conf file not found in the deployment package."
    exit 1
fi
