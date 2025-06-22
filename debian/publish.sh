#!/bin/bash
# Script to publish ramdisk-manager Debian package to a private APT repository

# Configuration - Edit these values to match your repository setup
REPO_PATH="/path/to/your/apt/repo"  # Path to your APT repository root
REPO_DIST="stable"                 # Repository distribution (e.g., stable, testing)
REPO_COMPONENT="main"              # Repository component

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 package.deb [version]"
  echo "Example: $0 ../ramdisk-manager_1.0.0_all.deb 1.0.0"
  exit 1
fi

PACKAGE_PATH="$1"
VERSION="${2:-1.0.0}"

# Check if package exists
if [ ! -f "${PACKAGE_PATH}" ]; then
  echo "Error: Package file ${PACKAGE_PATH} not found"
  exit 1
fi

# Check if reprepro is installed
if ! command -v reprepro &> /dev/null; then
  echo "Error: reprepro is not installed. Install it with:"
  echo "  sudo apt-get install reprepro"
  exit 1
fi

# Check if repository path exists
if [ ! -d "${REPO_PATH}" ]; then
  echo "Error: Repository path ${REPO_PATH} not found."
  echo "Please update the REPO_PATH variable in this script."
  exit 1
fi

# Optional: Sign the package
if command -v dpkg-sig &> /dev/null; then
  echo "Signing package with your GPG key..."
  dpkg-sig --sign builder "${PACKAGE_PATH}"
fi

# Add package to repository
echo "Adding package to repository ${REPO_PATH}..."
reprepro -b "${REPO_PATH}" includedeb "${REPO_DIST}" "${PACKAGE_PATH}"

# Check result
if [ $? -eq 0 ]; then
  echo "Package successfully added to your repository."
  echo
  echo "Repository URL: http://your-repo-url.example.com/"
  echo "Users can install it with:"
  echo "  sudo apt-add-repository 'deb http://your-repo-url.example.com ${REPO_DIST} ${REPO_COMPONENT}'"
  echo "  sudo apt-get update"
  echo "  sudo apt-get install ramdisk-manager"
else
  echo "Error: Failed to add package to repository."
  exit 1
fi
