#!/usr/bin/env python3
# RAM Disk System Tray Indicator
# Shows RAM disk usage in the system tray

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk, GLib, AppIndicator3
import subprocess
import os
import time
import threading

class RAMDiskIndicator:
    def __init__(self):
        self.indicator = AppIndicator3.Indicator.new(
            "ramdisk-indicator",
            "drive-harddisk-symbolic",  # Default icon
            AppIndicator3.IndicatorCategory.SYSTEM_SERVICES
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.update_interval = 60  # Update every 60 seconds
        
        # Setup the menu
        self.menu = Gtk.Menu()
        
        # Status item (will be updated)
        self.status_item = Gtk.MenuItem(label="Loading RAM disk status...")
        self.status_item.set_sensitive(False)
        self.menu.append(self.status_item)
        
        # Separator
        self.menu.append(Gtk.SeparatorMenuItem())
        
        # Open RAM disk folder
        item_open = Gtk.MenuItem(label="Open RAM Disk Folder")
        item_open.connect("activate", self.open_ramdisk)
        self.menu.append(item_open)
        
        # Show detailed status
        item_details = Gtk.MenuItem(label="Show Detailed Status")
        item_details.connect("activate", self.show_details)
        self.menu.append(item_details)
        
        # Run cleanup
        item_cleanup = Gtk.MenuItem(label="Run Cleanup")
        item_cleanup.connect("activate", self.run_cleanup)
        self.menu.append(item_cleanup)
        
        # Separator
        self.menu.append(Gtk.SeparatorMenuItem())
        
        # Quit
        item_quit = Gtk.MenuItem(label="Quit")
        item_quit.connect("activate", self.quit)
        self.menu.append(item_quit)
        
        self.menu.show_all()
        self.indicator.set_menu(self.menu)
        
        # Start the update thread
        self.running = True
        self.update_thread = threading.Thread(target=self.update_status_thread)
        self.update_thread.daemon = True
        self.update_thread.start()
        
    def get_ramdisk_usage(self):
        try:
            # Get RAM disk usage
            result = subprocess.run(
                ["du", "-sh", os.path.expanduser("~/.ramdisk")], 
                capture_output=True, text=True, check=True
            )
            usage = result.stdout.strip().split()[0]
            
            # Get total RAM disk size
            result = subprocess.run(
                ["df", "-h", "/mnt/ramdisk"], 
                capture_output=True, text=True, check=True
            )
            lines = result.stdout.strip().split("\n")
            if len(lines) >= 2:
                parts = lines[1].split()
                if len(parts) >= 2:
                    total = parts[1]
                else:
                    total = "16G"  # Fallback
            else:
                total = "16G"  # Fallback
                
            return f"RAM Disk: {usage} used / {total} total"
        except Exception as e:
            return f"RAM Disk: Error ({str(e)})"
    
    def update_status_thread(self):
        while self.running:
            status_text = self.get_ramdisk_usage()
            GLib.idle_add(self.update_status_label, status_text)
            time.sleep(self.update_interval)
    
    def update_status_label(self, text):
        self.status_item.set_label(text)
        return False
    
    def open_ramdisk(self, _):
        subprocess.Popen(["xdg-open", os.path.expanduser("~/.ramdisk")])
    
    def show_details(self, _):
        subprocess.Popen(["gnome-terminal", "--", "/home/davide/bin/ramdisk-status.sh"])
    
    def run_cleanup(self, _):
        subprocess.Popen(["gnome-terminal", "--", "/home/davide/bin/ramdisk-cleanup.sh"])
    
    def quit(self, _):
        self.running = False
        Gtk.main_quit()

if __name__ == "__main__":
    indicator = RAMDiskIndicator()
    Gtk.main()
