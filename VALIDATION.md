# RAM Disk Management System: Validation Process

This document outlines the steps to validate that the RAM disk management system works correctly on a clean installation. Follow these steps to ensure all components function as expected.

## 1. Preparation

### 1.1 Setting up a Test Environment

```bash
# Option 1: Use a physical machine with Ubuntu 24.04+
# Option 2: Create a virtual machine
```

- Set up a clean Ubuntu 24.04 VM using VirtualBox, QEMU, or another virtualization software
- Allocate at least 24GB RAM to the VM (32GB recommended for proper testing)
- Install Ubuntu with default settings
- Create a test user account similar to your production environment

### 1.2 Transfer Files

Transfer the `out/` directory to the test machine:

```bash
# If using a VM with shared folders
cp -r out/ /path/to/shared/folder/

# If using SCP (from source to test machine)
scp -r out/ testuser@testmachine:/home/testuser/
```

## 2. Installation Methods

### 2.1 Using the Installation Script

```bash
cd /path/to/copied/out
chmod +x install.sh
./install.sh
```

- Watch for any error messages during installation
- Answer any prompts that appear
- Log out and log back in after installation completes

### 2.2 Using the Debian Package (Optional)

If you've built the Debian package:

```bash
# On the source machine
cd /path/to/out/debian
./build.sh 1.0.0

# Transfer the .deb file to the test machine
scp ramdisk-manager_1.0.0_all.deb testuser@testmachine:/home/testuser/

# On the test machine
sudo apt install ./ramdisk-manager_1.0.0_all.deb
ramdisk-manager-setup
```

## 3. Validation Checklist

### 3.1 System Components

```bash
# Check if RAM disk is mounted
df -h | grep ramdisk
ls -la /mnt/ramdisk

# Check systemd mount unit status
systemctl status mnt-ramdisk.mount
```

Expected result: RAM disk should be mounted at `/mnt/ramdisk` with proper size (16GB) and permissions (1777).

### 3.2 User-Specific Setup

```bash
# Check if user directories are created
ls -la ~/.ramdisk

# Check symlinks
ls -la /mnt/ramdisk/$USER
```

Expected result:
- User directories should exist in `~/.ramdisk/` with 700 permissions
- Symlinks should point from `/mnt/ramdisk/$USER/` to `~/.ramdisk/`

### 3.3 Scripts and Utilities

```bash
# Check if scripts are installed and executable
ls -la ~/bin/chrome-ram ~/bin/firefox-ram ~/bin/gimp-ram ~/bin/inkscape-ram ~/bin/ffmpeg-ram
ls -la ~/bin/ramdisk-*.sh ~/bin/ramdisk-indicator.py

# Check if scripts are in PATH
which chrome-ram firefox-ram
```

### 3.4 Environment Configuration

```bash
# Check if TMPDIR is correctly set
echo $TMPDIR

# Check .bashrc configuration
grep -A 2 "RAM disk" ~/.bashrc
```

Expected result: `$TMPDIR` should point to `~/.ramdisk/tmp`

### 3.5 Desktop Integration

```bash
# Check desktop files
ls -la ~/.local/share/applications/*ram*.desktop

# Check menu entries
find /usr/share/applications ~/.local/share/applications -name "*ram*.desktop" | xargs cat
```

### 3.6 Autostart Entries

```bash
# Check autostart entries
ls -la ~/.config/autostart/ramdisk-*.desktop
```

### 3.7 Cron Jobs

```bash
# Check if cleanup cron job is installed
crontab -l | grep ramdisk
```

Expected result: Cron entry for `ramdisk-cleanup.sh` should be present, scheduled daily at 3 AM

## 4. Functional Testing

### 4.1 Application Launchers

Test launching each RAM disk-enabled application:

```bash
chrome-ram
firefox-ram
gimp-ram
inkscape-ram
ffmpeg-ram -version  # Just check if it runs correctly
```

Verify that each application starts properly and uses the RAM disk for temporary files.

### 4.2 Firefox Configuration

For Firefox, verify the cache settings:

1. Launch Firefox with `firefox-ram`
2. Go to `about:config` in the address bar
3. Search for `browser.cache.disk.parent_directory`
4. Verify it points to your RAM disk cache directory (`~/.ramdisk/firefox-cache`)

### 4.3 RAM Disk Utilities

Test each utility:

```bash
# Status utility
ramdisk-status.sh

# Benchmark utility
ramdisk-benchmark.sh

# Cleanup utility
ramdisk-cleanup.sh
```

### 4.4 System Tray Indicator

1. Verify the RAM disk indicator appears in system tray after login
2. Test each menu option:
   - Open RAM Disk Folder
   - Show RAM Disk Status
   - Clean Up RAM Disk
   - Quit

## 5. Performance Validation

```bash
# Run the benchmark script
ramdisk-benchmark.sh

# Create and read a large file
dd if=/dev/urandom of=~/.ramdisk/tmp/testfile bs=1M count=1000
dd if=~/.ramdisk/tmp/testfile of=/dev/null bs=1M
```

Expected result: RAM disk operations should be significantly faster than equivalent operations on the regular disk.

## 6. Edge Cases

### 6.1 Reboot Testing

Reboot the system and verify:

1. RAM disk is automatically mounted
2. User directories are correctly reinitialized
3. Environment variables are set correctly
4. Indicator starts automatically

### 6.2 Multiple User Testing

If possible, create a second user account and verify:

1. RAM disk remains accessible to all users
2. User-specific directories are properly isolated
3. Second user can run the setup and use RAM disk features

## 7. Uninstallation Testing

### 7.1 If installed via script:
No formal uninstallation process, manually remove components:
```bash
# Disable systemd mount unit
sudo systemctl stop mnt-ramdisk.mount
sudo systemctl disable mnt-ramdisk.mount
sudo rm /etc/systemd/system/mnt-ramdisk.mount

# Remove user files (backup first if needed)
rm -f ~/bin/chrome-ram ~/bin/firefox-ram ~/bin/gimp-ram ~/bin/inkscape-ram ~/bin/ffmpeg-ram
rm -f ~/bin/ramdisk-*.sh ~/bin/ramdisk-indicator.py ~/bin/setup-ramdisk-cron.sh
rm -rf ~/.ramdisk

# Remove desktop and autostart entries
rm -f ~/.local/share/applications/*ram*.desktop
rm -f ~/.config/autostart/ramdisk-*.desktop

# Remove cron job
crontab -l | grep -v "ramdisk-cleanup" | crontab -
```

### 7.2 If installed via Debian package:
```bash
sudo apt remove ramdisk-manager
```

Then clean up user files as described above.

## 8. Troubleshooting Common Issues

### 8.1 Permission Problems
If experiencing permission errors:
```bash
# Check permissions
ls -la /mnt/ramdisk
ls -la ~/.ramdisk

# Fix if needed
chmod 700 ~/.ramdisk
```

### 8.2 Mount Issues
If RAM disk doesn't mount:
```bash
# Check mount unit
sudo systemctl status mnt-ramdisk.mount

# Check system logs
journalctl -u mnt-ramdisk.mount

# Manual mount command (temporary)
sudo mount -t tmpfs -o size=16G,noatime,mode=1777 tmpfs /mnt/ramdisk
```

## 9. Validation Report

Complete this report after testing:

```
RAM Disk Management System Validation Report
-------------------------------------------
Date: [Test Date]
Tester: [Your Name]
Ubuntu Version: [e.g., 24.04]
Hardware: [VM or Physical, RAM Size]

System Components:
[ ] RAM disk correctly mounted
[ ] Systemd unit active
[ ] User directories created with correct permissions

User Setup:
[ ] Home directories and symlinks correct
[ ] TMPDIR environment variable set
[ ] PATH includes ~/bin

Applications:
[ ] Chrome RAM wrapper works
[ ] Firefox RAM wrapper works
[ ] GIMP RAM wrapper works
[ ] Inkscape RAM wrapper works
[ ] FFmpeg RAM wrapper works

Utilities:
[ ] Status utility works
[ ] Benchmark utility works
[ ] Cleanup utility works
[ ] Cron job scheduled

Desktop Integration:
[ ] Desktop entries created
[ ] Autostart entries active
[ ] Indicator appears in system tray

Performance:
[ ] Benchmark shows significant improvement
[ ] Applications load faster
[ ] Cache operations faster

Overall Assessment:
[ ] PASS - All components working as expected
[ ] PARTIAL PASS - Minor issues (list below)
[ ] FAIL - Major issues (list below)

Issues Found:
1. 
2.

Recommendations:
1.
2.
```
