#!/bin/bash
# RAM Disk Cleanup Tool
# Removes old and unused files from the RAM disk

echo "===== RAM Disk Cleanup ====="
echo "Starting cleanup at $(date)"

# Define cleanup age (files older than 2 days)
MAX_AGE=2

# Show initial disk usage
echo "Before cleanup:"
du -sh ${HOME}/.ramdisk

# Clean temporary files older than MAX_AGE days
echo -e "\nCleaning temporary files..."
find ${HOME}/.ramdisk/tmp -type f -mtime +${MAX_AGE} -delete 2>/dev/null
find ${HOME}/.ramdisk/ffmpeg-tmp -type f -mtime +${MAX_AGE} -delete 2>/dev/null
find ${HOME}/.ramdisk/gimp-tmp -type f -mtime +${MAX_AGE} -delete 2>/dev/null
find ${HOME}/.ramdisk/inkscape-tmp -type f -mtime +${MAX_AGE} -delete 2>/dev/null

# Clean browser caches that are older 
echo -e "\nCleaning browser cache files..."
find ${HOME}/.ramdisk/firefox-cache -type f -mtime +${MAX_AGE} -delete 2>/dev/null
find ${HOME}/.ramdisk/chrome-profile/cache -type f -mtime +${MAX_AGE} -delete 2>/dev/null

# Show final disk usage
echo -e "\nAfter cleanup:"
du -sh ${HOME}/.ramdisk

echo -e "\nCleanup completed at $(date)"
echo "============================"
