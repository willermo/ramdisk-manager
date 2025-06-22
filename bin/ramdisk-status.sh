#!/bin/bash
# RAM Disk Status Monitor
# Shows usage statistics for the RAM disk and user directories

echo "==============================================="
echo "RAM Disk Status - $(date)"
echo "==============================================="
echo

# System RAM disk mount
echo "System RAM Disk Mount:"
df -h /mnt/ramdisk | grep -v "Filesystem"
echo

# User RAM directories
echo "User RAM Directories:"
du -sh ${HOME}/.ramdisk/* | sort -hr
echo

# Total usage
echo "Total User RAM Disk Usage:"
du -sh ${HOME}/.ramdisk
echo

# System memory status
echo "System Memory Status:"
free -h
echo "==============================================="
