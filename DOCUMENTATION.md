# RAM Disk Management System Documentation

## Overview

This RAM disk management system optimizes system performance by utilizing a portion of your RAM (16GB recommended) as a high-speed storage area for temporary files, browser profiles, and application caches. It provides significant speed improvements for I/O intensive operations while protecting your SSD/HDD from excessive write operations.

## System Components

### 1. Core Components

#### Systemd Mount Unit (`mnt-ramdisk.mount`)
- **Purpose**: Creates and mounts a 16GB RAM disk at `/mnt/ramdisk`
- **Location**: `/etc/systemd/system/mnt-ramdisk.mount`
- **Permissions**: System-level configuration (requires root)
- **Key settings**:
  - `size=16G`: Allocates 16GB of RAM
  - `mode=1777`: World-writable with sticky bit
  - `noatime`: Improves performance by not updating access times

#### User Directory Structure
- **Main Directory**: `~/.ramdisk/` 
- **Purpose**: Stores user-specific temporary files with proper permissions
- **Key Structure**:
  - Only username directories should be directly under `/mnt/ramdisk/` (e.g., `/mnt/ramdisk/username/`)
  - Each username directory is a symlink to the user's `~/.ramdisk` directory
  - All application-specific directories live under `~/.ramdisk/` with proper ownership and permissions
- **Subdirectories**:
  - `tmp`: General temporary files
  - `chrome-profile`: Chrome browser profile
  - `firefox-cache`: Firefox cache
  - `gimp-tmp`, `inkscape-tmp`, `ffmpeg-tmp`: Application-specific temp files
  - `docker-tmp`: Docker build cache and temporary files
  - `windsurf-cache`: Windsurf IDE cache
  - `browser-cache`: Additional browser cache
  - `system-cache`: System-level cache files

### 2. Application Wrappers

#### Chrome Wrapper (`chrome-ram`)
- **Purpose**: Launches Chrome with profile and cache in RAM
- **Location**: `~/bin/chrome-ram`
- **Usage**: `chrome-ram [chrome-args]`
- **Key features**:
  - User profile stored in RAM
  - Optimized cache settings
  - Performance flags for improved rendering

#### Firefox Wrapper (`firefox-ram`)
- **Purpose**: Sets up Firefox to use RAM for cache and temporary files
- **Location**: `~/bin/firefox-ram`
- **Usage**: `firefox-ram [firefox-args]`
- **Key features**:
  - Auto-configures Firefox user.js
  - Sets up proper cache directories
  - Optimizes memory and disk cache settings

#### Other Application Wrappers
- `gimp-ram`: GIMP with temporary files, swap files, and GTK cache in RAM
- `inkscape-ram`: Inkscape with temporary files, autosave, and GTK cache in RAM
- `ffmpeg-ram`: FFmpeg with optimized temporary directories and performance flags
- `docker-ram`: Docker with build cache in RAM for faster container builds
- `windsurf-ram-setup.sh`: Setup script for Windsurf IDE RAM disk integration
- All follow similar pattern of redirecting temporary files, caches, and work files to RAM

#### Environment Setup (`set-tmpdir-env.sh`)
- **Purpose**: Sets TMPDIR for shell sessions
- **Location**: `~/bin/set-tmpdir-env.sh`
- **Usage**: `source ~/bin/set-tmpdir-env.sh`
- **Integration**: Added to `.bashrc` for persistence

### 3. Management Tools

#### RAM Disk Setup (`ramdisk-setup.sh`)
- **Purpose**: Initializes directories and symlinks
- **Location**: `~/bin/ramdisk-setup.sh`
- **Usage**: Runs automatically at login via autostart
- **Key features**:
  - Creates necessary directories
  - Sets proper permissions
  - Creates symbolic links between home and RAM disk

#### RAM Disk Status (`ramdisk-status.sh`)
- **Purpose**: Shows RAM disk usage statistics
- **Location**: `~/bin/ramdisk-status.sh`
- **Usage**: Run manually to check status
- **Output**: Shows usage by directory, total usage, and system memory status

#### RAM Disk Cleanup (`ramdisk-cleanup.sh`)
- **Purpose**: Removes old files from RAM disk
- **Location**: `~/bin/ramdisk-cleanup.sh`
- **Usage**: Runs daily via cron or manually
- **Behavior**: Deletes files older than 2 days

#### RAM Disk Benchmark (`ramdisk-benchmark.sh`)
- **Purpose**: Compares RAM disk vs regular disk performance
- **Location**: `~/bin/ramdisk-benchmark.sh`
- **Usage**: Run manually to see performance difference
- **Tests**: Read and write tests with varying file sizes

#### RAM Disk System Tray Indicator (`ramdisk-indicator.py`)
- **Purpose**: Shows RAM disk usage in system tray
- **Location**: `~/bin/ramdisk-indicator.py`
- **Usage**: Starts automatically at login
- **Features**: Shows usage, quick access to tools

### 4. Desktop Integration

#### Application Launchers
- **Purpose**: Allow launching RAM disk versions from dock/menu
- **Location**: `~/.local/share/applications/*.desktop`
- **Files**:
  - `google-chrome-ram.desktop`: Chrome with RAM disk optimizations
  - `firefox-ram-note.desktop`: Firefox with RAM disk optimizations
  - `gimp-ram.desktop`: GIMP with RAM disk optimizations
  - `inkscape-ram.desktop`: Inkscape with RAM disk optimizations
  - `windsurf-ram.desktop`: Windsurf IDE with RAM disk optimizations

#### Autostart Entries
- **Purpose**: Start RAM disk services at login
- **Location**: `~/.config/autostart/*.desktop`
- **Files**:
  - `ramdisk-setup.desktop`
  - `ramdisk-indicator.desktop`

## Installation Process

1. **System Mount Configuration**:
   - Install systemd mount unit
   - Enable and start the mount service

2. **Script Installation**:
   - Copy scripts to `~/bin/`
   - Make scripts executable
   - Update `.bashrc` to source environment script

3. **Desktop Integration**:
   - Install desktop launchers
   - Set up autostart entries
   - Configure browser profiles (especially Firefox)

4. **Automated Maintenance**:
   - Set up daily cleanup cron job
   - Initialize RAM disk directories

## Usage Guide

### Basic Usage

1. **Launch Applications**:
   - Use dock icons with "RAM" suffix
   - Or launch from terminal with `-ram` suffix: `chrome-ram`, `firefox-ram`, etc.

2. **Monitor Usage**:
   - System tray icon shows current usage
   - Detailed statistics: `ramdisk-status.sh`
   - Run benchmark: `ramdisk-benchmark.sh`

3. **Maintenance**:
   - Manual cleanup: `ramdisk-cleanup.sh`
   - Automatic cleanup happens daily at 3 AM

### Firefox Configuration

Firefox requires manual configuration after installation:
1. Launch Firefox using `firefox-ram`
2. Navigate to `about:config`
3. Search for `browser.cache.disk.parent_directory`
4. Set it to `${HOME}/.ramdisk/firefox-cache`

### Troubleshooting

**Issue**: RAM disk not mounted
- Check systemd service: `systemctl status mnt-ramdisk.mount`
- Ensure mount unit is enabled: `systemctl enable mnt-ramdisk.mount`

**Issue**: Permission problems
- Check directory ownership: `ls -la ~/.ramdisk/`
- Run setup script again: `~/bin/ramdisk-setup.sh`

**Issue**: Application doesn't use RAM disk
- Verify wrapper script is being used: `which chrome-ram`
- Check process environment: `ps -e | grep chrome`

**Issue**: RAM disk performance issues
- Run benchmark to compare performance: `ramdisk-benchmark.sh`
- Check for disk space issues: `ramdisk-status.sh`

## Security Considerations

- User directories have `700` permissions (only accessible by owner)
- System mount point has sticky bit (`1777`) preventing users from modifying each others' files
- All temporary RAM disk content is lost on reboot (security benefit)
- No sensitive data should be permanently stored in RAM disk

## Performance Expectations

- Read speeds: 5-20x faster than SSD
- Write speeds: 10-30x faster than SSD
- Best for: compilation, video editing, browser caches, temporary files
- May not benefit: small files, infrequent access patterns

## System Requirements

- Minimum 24GB total RAM (16GB for system + 8GB for RAM disk)
- Recommended: 32GB+ total RAM (16GB for RAM disk)
- Ubuntu 24.04 or compatible Linux distribution
- systemd init system
