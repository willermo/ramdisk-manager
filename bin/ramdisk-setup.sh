#!/bin/bash
# Script to set up RAM disk directories and permissions on boot
# Place in ~/bin/ and add to startup applications

# Set username for proper directory ownership
USERNAME=$(whoami)
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Create user-specific directories in the RAM disk
# We create these in the user's home space to avoid permission issues
mkdir -p ${HOME}/.ramdisk/{tmp,chrome-profile,firefox-cache,gimp-tmp,inkscape-tmp,ffmpeg-tmp,browser-cache,system-cache}

# Create symlinks from ramdisk mount to user directories
for dir in tmp chrome-profile firefox-cache gimp-tmp inkscape-tmp ffmpeg-tmp browser-cache system-cache; do
  if [ ! -d "/mnt/ramdisk/${USERNAME}" ]; then
    mkdir -p "/mnt/ramdisk/${USERNAME}" 2>/dev/null || true
  fi
  ln -sf "${HOME}/.ramdisk/${dir}" "/mnt/ramdisk/${USERNAME}/${dir}" 2>/dev/null || true
done

# Create symlinks for commonly used cache directories
if [ ! -L ~/.cache/mozilla ]; then
  # Back up existing Firefox cache if it exists
  if [ -d ~/.cache/mozilla ]; then
    mv ~/.cache/mozilla ~/.cache/mozilla.backup
  fi
  ln -sf "${HOME}/.ramdisk/firefox-cache" ~/.cache/mozilla
fi

# Set environment variable for the session
export TMPDIR="${HOME}/.ramdisk/tmp"

# Update the TMPDIR environment variable in the shell configuration
grep -q "export TMPDIR=\"${HOME}/.ramdisk/tmp\"" ~/.bashrc || echo "export TMPDIR=\"${HOME}/.ramdisk/tmp\"" >> ~/.bashrc

# Notify user
notify-send "RAM Disk Setup" "16GB RAM disk is ready at /mnt/ramdisk"

echo "RAM disk setup complete at $(date)"
