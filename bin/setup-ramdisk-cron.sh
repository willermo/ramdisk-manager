#!/bin/bash
# Set up automated cleanup for RAM disk

# Check if crontab entry already exists
if crontab -l | grep -q "ramdisk-cleanup.sh"; then
    echo "Cron job for RAM disk cleanup already exists."
else
    # Create temporary file with current crontab
    crontab -l > /tmp/current-crontab 2>/dev/null || echo "" > /tmp/current-crontab
    
    # Add our cleanup job to run daily at 3 AM
    echo "# RAM disk cleanup - runs daily at 3 AM" >> /tmp/current-crontab
    echo "0 3 * * * /home/davide/bin/ramdisk-cleanup.sh > /home/davide/.ramdisk/cleanup.log 2>&1" >> /tmp/current-crontab
    
    # Install the new crontab
    crontab /tmp/current-crontab
    rm /tmp/current-crontab
    
    echo "Cron job for RAM disk cleanup installed successfully."
    echo "It will run daily at 3 AM."
fi
