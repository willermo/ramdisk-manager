#!/bin/bash
# Build script for ramdisk-manager Debian package

# Set version from command line or use default
VERSION=${1:-1.0.0}
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${PACKAGE_ROOT}/ramdisk-manager"
OUTPUT_DIR="${PACKAGE_ROOT}/../"

echo "Building ramdisk-manager package version ${VERSION}..."

# Update version in control file
sed -i "s/^Version: .*/Version: ${VERSION}/" "${PACKAGE_DIR}/DEBIAN/control"

# Copy the systemd mount unit
cp "${OUTPUT_DIR}/../mnt-ramdisk.mount" "${PACKAGE_DIR}/etc/systemd/system/"

# Create the ramdisk-manager-setup script in usr/bin
mkdir -p "${PACKAGE_DIR}/usr/bin"

# Copy shared files
echo "Copying script files..."
mkdir -p "${PACKAGE_DIR}/usr/share/ramdisk-manager/bin"
cp "${OUTPUT_DIR}/bin/"* "${PACKAGE_DIR}/usr/share/ramdisk-manager/bin/"

echo "Copying desktop files..."
mkdir -p "${PACKAGE_DIR}/usr/share/ramdisk-manager/desktop"
cp "${OUTPUT_DIR}/desktop/"*.desktop "${PACKAGE_DIR}/usr/share/ramdisk-manager/desktop/" 2>/dev/null || echo "No desktop files found"

echo "Copying autostart files..."
mkdir -p "${PACKAGE_DIR}/usr/share/ramdisk-manager/autostart"
cp "${OUTPUT_DIR}/autostart/"*.desktop "${PACKAGE_DIR}/usr/share/ramdisk-manager/autostart/" 2>/dev/null || echo "No autostart files found"

# Copy documentation
echo "Copying documentation..."
mkdir -p "${PACKAGE_DIR}/usr/share/doc/ramdisk-manager"
cp "${OUTPUT_DIR}/DOCUMENTATION.md" "${PACKAGE_DIR}/usr/share/doc/ramdisk-manager/"
cp "${OUTPUT_DIR}/RECOMMENDATIONS.md" "${PACKAGE_DIR}/usr/share/doc/ramdisk-manager/"

# Build the package
echo "Building Debian package..."
dpkg-deb --build "${PACKAGE_DIR}" "${OUTPUT_DIR}/ramdisk-manager_${VERSION}_all.deb"

# Check if build was successful
if [ -f "${OUTPUT_DIR}/ramdisk-manager_${VERSION}_all.deb" ]; then
  echo "Package built successfully: ${OUTPUT_DIR}/ramdisk-manager_${VERSION}_all.deb"
  
  # Run lintian if available
  if command -v lintian &> /dev/null; then
    echo "Running lintian to check package quality..."
    lintian "${OUTPUT_DIR}/ramdisk-manager_${VERSION}_all.deb"
  fi
else
  echo "Failed to build package!"
  exit 1
fi
