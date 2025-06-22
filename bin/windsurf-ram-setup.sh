#!/bin/bash
# Windsurf IDE RAM disk optimization setup
# Creates RAM disk directories for Windsurf IDE cache and links them

# Create RAM disk directories
WINDSURF_RAMDISK=${HOME}/.ramdisk/windsurf-cache
mkdir -p "$WINDSURF_RAMDISK"/{Cache,CachedData,CachedExtensions,Code\ Cache}
chmod 700 "$WINDSURF_RAMDISK"

# Check for existing Windsurf configuration directories
WINDSURF_CONFIG_DIR=${HOME}/.config/Windsurf
if [ ! -d "$WINDSURF_CONFIG_DIR" ]; then
  echo "Windsurf IDE configuration directory not found. Creating directory structure."
  mkdir -p "$WINDSURF_CONFIG_DIR"
fi

# Back up existing cache directories if they exist
for dir in Cache "CachedData" "CachedExtensions" "Code Cache"; do
  if [ -d "$WINDSURF_CONFIG_DIR/$dir" ] && [ ! -L "$WINDSURF_CONFIG_DIR/$dir" ]; then
    echo "Backing up existing $dir to ${WINDSURF_CONFIG_DIR}/${dir}.backup"
    mv "$WINDSURF_CONFIG_DIR/$dir" "${WINDSURF_CONFIG_DIR}/${dir}.backup"
  elif [ -L "$WINDSURF_CONFIG_DIR/$dir" ]; then
    echo "Symbolic link for $dir already exists. Removing and recreating."
    rm "$WINDSURF_CONFIG_DIR/$dir"
  fi
done

# Create symbolic links to RAM disk
echo "Creating symbolic links for Windsurf IDE cache directories..."
ln -sf "$WINDSURF_RAMDISK/Cache" "$WINDSURF_CONFIG_DIR/Cache"
ln -sf "$WINDSURF_RAMDISK/CachedData" "$WINDSURF_CONFIG_DIR/CachedData"
ln -sf "$WINDSURF_RAMDISK/CachedExtensions" "$WINDSURF_CONFIG_DIR/CachedExtensions"
ln -sf "$WINDSURF_RAMDISK/Code Cache" "$WINDSURF_CONFIG_DIR/Code Cache"

# Create windsurf-ram wrapper script
WINDSURF_WRAPPER=${HOME}/bin/windsurf-ram
cat > "$WINDSURF_WRAPPER" << 'EOL'
#!/bin/bash
# Windsurf IDE RAM disk wrapper

# Ensure RAM disk directories exist
${HOME}/.ramdisk/windsurf-ram-setup.sh > /dev/null 2>&1

# Set environment variables for performance
export WINDSURF_DISABLE_CRASH_REPORTER=1
export WINDSURF_DISABLE_TELEMETRY=1

# Launch Windsurf IDE with RAM disk optimizations
windsurf "$@"
EOL

chmod +x "$WINDSURF_WRAPPER"

echo "Windsurf IDE RAM disk optimization setup complete!"
echo "You can now use 'windsurf-ram' to launch Windsurf IDE with RAM disk optimizations."
