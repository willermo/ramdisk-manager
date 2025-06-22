# RAM Disk Manager

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04%2B-orange)

A comprehensive RAM disk management system for Ubuntu that optimizes performance by strategically utilizing RAM for temporary files, browser profiles, and application caches.

## 🚀 Overview

**RAM Disk Manager** creates a seamless RAM disk environment that:

- 🔄 Allocates a portion of RAM (default: 16GB) as high-performance storage
- 🌐 Optimizes browsers (Chrome, Firefox) with RAM disk profiles and caches
- 🎨 Accelerates creative tools (GIMP, Inkscape) by redirecting temp files to RAM
- 🎬 Enhances media processing (FFmpeg) with RAM disk temp storage
- 🔒 Provides user-specific isolation with proper security model
- 🧹 Includes automatic maintenance and cleanup utilities
- 🔍 Features real-time monitoring via system tray indicator

Perfect for high-memory systems (32GB+ RAM) where I/O operations become bottlenecks and cause unnecessary SSD/HDD wear.

## 💻 Requirements

- Ubuntu 24.04 or newer (may work on other Debian-based distributions)
- At least 24GB RAM (recommended: 32GB+)
- At least 16GB will be allocated to RAM disk

## ⚙️ Installation

### Option 1: Using the installation script

```bash
# Clone the repository
git clone https://github.com/willermo/ramdisk-manager.git

# Run the installer
cd ramdisk-manager
./install.sh
```

### Option 2: Using the Debian package (Coming soon)

```bash
# Add repository (placeholder)
sudo apt-add-repository 'deb https://your-repo.example.com stable main'
sudo apt update

# Install package
sudo apt install ramdisk-manager

# Complete user setup
ramdisk-manager-setup
```

## 🖥️ Usage

After installation, you can use these wrapper scripts to launch applications with RAM disk integration:

```bash
# Launch browsers with RAM disk profiles
chrome-ram
firefox-ram

# Launch creative applications with RAM disk temp files
gimp-ram
inkscape-ram

# Use FFmpeg with RAM disk temp directory
ffmpeg-ram -i input.mp4 -c:v libx264 output.mp4
```

### Management Utilities

```bash
# Show RAM disk status and usage
ramdisk-status.sh

# Benchmark RAM disk performance
ramdisk-benchmark.sh

# Clean up old files
ramdisk-cleanup.sh
```

A system tray indicator provides real-time monitoring and quick access to RAM disk utilities.

## 📁 Directory Structure

The RAM disk creates:

- 📂 System-level: `/mnt/ramdisk` (16GB tmpfs, mode 1777)
- 📂 User-level: `~/.ramdisk/` (700 permissions) with:
  - `~/ramdisk/tmp` - General temporary files
  - `~/ramdisk/chrome-profile` - Chrome user profile
  - `~/ramdisk/firefox-profile` - Firefox user profile
  - `~/ramdisk/firefox-cache` - Firefox cache
  - `~/ramdisk/gimp-tmp` - GIMP temporary files
  - `~/ramdisk/inkscape-tmp` - Inkscape temporary files
  - `~/ramdisk/ffmpeg-tmp` - FFmpeg temporary files

## 📚 Documentation

- [Full Documentation](DOCUMENTATION.md) - Complete system guide
- [Validation Guide](VALIDATION.md) - Testing procedures
- [Additional Optimizations](RECOMMENDATIONS.md) - More RAM disk use cases
- [APT Packaging Guide](APT_PACKAGING.md) - Debian packaging details

## 🔄 Persistence

The RAM disk contents are temporary and will be lost on system shutdown or reboot. The directory structure is automatically recreated on login.

For Firefox, the profile is persistent (stored in `~/.mozilla/firefox`) while the cache is in RAM.

## 🛠️ Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

Created by Davide Oriani (willermo@gmail.com) - June 2025
