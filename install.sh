#!/bin/bash
# RAM Disk Management System - Installation Script
# This script installs the RAM disk management system for Ubuntu-based distributions
# Author: Davide
# Date: June 2025

# Text formatting
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Script must run as normal user, not as root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}${BOLD}Error:${RESET} This script should NOT be run as root or with sudo."
    echo "Please run it as your regular user account. It will ask for sudo password when needed."
    exit 1
fi

# Current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}${BOLD}=========================================================${RESET}"
echo -e "${BLUE}${BOLD}     RAM Disk Management System - Installation           ${RESET}"
echo -e "${BLUE}${BOLD}=========================================================${RESET}"
echo

# Check system requirements
echo -e "${YELLOW}Checking system requirements...${RESET}"
TOTAL_MEM=$(free -g | awk '/^Mem:/ {print $2}')
if [ "$TOTAL_MEM" -lt 24 ]; then
    echo -e "${RED}${BOLD}Warning:${RESET} Your system has less than 24GB RAM ($TOTAL_MEM GB detected)."
    echo "The recommended configuration is for systems with at least 24GB RAM."
    echo "You may need to adjust the RAM disk size in the mount unit file."
    echo
    read -p "Do you want to continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# 1. Install systemd mount unit
echo -e "${YELLOW}Installing systemd mount unit...${RESET}"
echo -e "This will create a 16GB RAM disk at /mnt/ramdisk"
echo -e "You'll be asked for your sudo password to install the mount unit."
echo

# Create mount point if it doesn't exist
sudo mkdir -p /mnt/ramdisk

# Install systemd mount unit
sudo cp "$SCRIPT_DIR/systemd/mnt-ramdisk.mount" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mnt-ramdisk.mount
sudo systemctl start mnt-ramdisk.mount

echo -e "${GREEN}Systemd mount unit installed and activated.${RESET}"
echo

# 2. Install script files
echo -e "${YELLOW}Installing RAM disk scripts...${RESET}"

# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Copy all script files
cp "$SCRIPT_DIR/bin/"* ~/bin/

# Make scripts executable
chmod +x ~/bin/chrome-ram ~/bin/firefox-ram ~/bin/gimp-ram ~/bin/inkscape-ram ~/bin/ffmpeg-ram \
       ~/bin/set-tmpdir-env.sh ~/bin/ramdisk-setup.sh ~/bin/ramdisk-status.sh \
       ~/bin/ramdisk-cleanup.sh ~/bin/ramdisk-benchmark.sh ~/bin/ramdisk-indicator.py \
       ~/bin/setup-ramdisk-cron.sh

echo -e "${GREEN}RAM disk scripts installed to ~/bin/${RESET}"
echo

# 3. Add bin directory to PATH if not already there
echo -e "${YELLOW}Updating PATH configuration...${RESET}"
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo -e "${GREEN}Added ~/bin to PATH in ~/.bashrc${RESET}"
fi

# 4. Add environment setup to .bashrc
echo -e "${YELLOW}Updating .bashrc with RAM disk environment settings...${RESET}"
if ! grep -q "source ~/bin/set-tmpdir-env.sh" ~/.bashrc; then
    echo "# Use RAM disk for temporary files" >> ~/.bashrc
    echo "source ~/bin/set-tmpdir-env.sh" >> ~/.bashrc
    echo -e "${GREEN}Added RAM disk environment setup to ~/.bashrc${RESET}"
else
    echo -e "${GREEN}RAM disk environment setup already in ~/.bashrc${RESET}"
fi

# 5. Install desktop files
echo -e "${YELLOW}Installing desktop launcher files...${RESET}"
mkdir -p ~/.local/share/applications

# Copy desktop files
cp "$SCRIPT_DIR/desktop/"*.desktop ~/.local/share/applications/

echo -e "${GREEN}Desktop launchers installed${RESET}"
echo

# 6. Install autostart files
echo -e "${YELLOW}Setting up autostart entries...${RESET}"
mkdir -p ~/.config/autostart

# Copy autostart files
cp "$SCRIPT_DIR/autostart/"*.desktop ~/.config/autostart/

echo -e "${GREEN}Autostart entries installed${RESET}"
echo

# 7. Set up cron job for daily cleanup
echo -e "${YELLOW}Setting up automated cleanup...${RESET}"
~/bin/setup-ramdisk-cron.sh

echo -e "${GREEN}Daily cleanup scheduled${RESET}"
echo

# 8. Install Python dependencies for the indicator
echo -e "${YELLOW}Installing dependencies for RAM disk indicator...${RESET}"
sudo apt-get update
sudo apt-get install -y python3-gi gir1.2-appindicator3-0.1

echo -e "${GREEN}Dependencies installed${RESET}"
echo

# 9. Initialize the RAM disk
echo -e "${YELLOW}Initializing RAM disk...${RESET}"
~/bin/ramdisk-setup.sh

echo -e "${GREEN}RAM disk initialized${RESET}"
echo

echo -e "${BLUE}${BOLD}=========================================================${RESET}"
echo -e "${GREEN}${BOLD}Installation Complete!${RESET}"
echo -e "${BLUE}${BOLD}=========================================================${RESET}"
echo
echo -e "${BOLD}Next steps:${RESET}"
echo "1. Log out and log back in (or restart your computer)"
echo "2. For Firefox, launch using firefox-ram then configure the cache:"
echo "   - Go to about:config"
echo "   - Search for browser.cache.disk.parent_directory"
echo "   - Set it to $HOME/.ramdisk/firefox-cache"
echo
echo "Use these commands to manage your RAM disk:"
echo "- ramdisk-status.sh    - Check RAM disk usage"
echo "- ramdisk-cleanup.sh   - Clean up old files"
echo "- ramdisk-benchmark.sh - Test RAM disk performance"
echo
echo "Launch applications with RAM disk support using:"
echo "- chrome-ram, firefox-ram, gimp-ram, inkscape-ram, ffmpeg-ram"
echo
echo -e "${YELLOW}For more details, see the DOCUMENTATION.md file${RESET}"
echo -e "${BLUE}${BOLD}=========================================================${RESET}"
