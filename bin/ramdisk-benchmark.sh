#!/bin/bash
# RAM Disk Performance Benchmark
# This script tests the read/write performance of your RAM disk vs regular disk

echo "===================================================="
echo "RAM DISK VS REGULAR DISK PERFORMANCE BENCHMARK"
echo "===================================================="
echo "Starting benchmark at $(date)"
echo

# File sizes for testing (in MB)
SIZES=(10 100 500)

# Create test directories if they don't exist
RAMDISK_TEST="${HOME}/.ramdisk/benchmark-test"
DISK_TEST="${HOME}/benchmark-test"

mkdir -p "$RAMDISK_TEST" "$DISK_TEST"

echo "Testing write performance..."
echo "---------------------------"
for SIZE in "${SIZES[@]}"; do
    echo "Testing ${SIZE}MB file size:"
    
    # RAM disk write test
    echo -n "RAM Disk write: "
    time dd if=/dev/zero of="${RAMDISK_TEST}/testfile" bs=1M count=${SIZE} status=none
    
    # Regular disk write test
    echo -n "Regular disk write: "
    time dd if=/dev/zero of="${DISK_TEST}/testfile" bs=1M count=${SIZE} status=none
    
    echo
done

echo
echo "Testing read performance..."
echo "---------------------------"
for SIZE in "${SIZES[@]}"; do
    echo "Testing ${SIZE}MB file size:"
    
    # Ensure files exist with correct size
    dd if=/dev/zero of="${RAMDISK_TEST}/testfile" bs=1M count=${SIZE} status=none
    dd if=/dev/zero of="${DISK_TEST}/testfile" bs=1M count=${SIZE} status=none
    
    # Clear caches to ensure fair testing
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    
    # RAM disk read test
    echo -n "RAM Disk read: "
    time dd if="${RAMDISK_TEST}/testfile" of=/dev/null bs=1M status=none
    
    # Regular disk read test
    echo -n "Regular disk read: "
    time dd if="${DISK_TEST}/testfile" of=/dev/null bs=1M status=none
    
    echo
done

# Clean up test files
rm -f "${RAMDISK_TEST}/testfile" "${DISK_TEST}/testfile"
rmdir "$DISK_TEST" 2>/dev/null

echo "===================================================="
echo "Benchmark completed at $(date)"
echo "===================================================="
