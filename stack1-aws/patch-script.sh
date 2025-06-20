#!/bin/bash
# patch-script.sh - Ubuntu patch management script for Arc VMs

SERVER_NAME="${server_name}"
LOG_FILE="/var/log/azure-patch-management.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVER_NAME] $1" | tee -a "$LOG_FILE"
}

log "Starting patch management process"

# Pre-patch system info
log "Pre-patch system info:"
log "Kernel: $(uname -r)"
log "Ubuntu version: $(lsb_release -d | cut -f2)"
log "Available updates: $(apt list --upgradable 2>/dev/null | wc -l)"

# Update package lists
log "Updating package lists..."
if sudo apt update; then
    log "Package lists updated successfully"
else
    log "ERROR: Failed to update package lists"
    exit 1
fi

# Show available updates
log "Available updates:"
sudo apt list --upgradable 2>/dev/null | tee -a "$LOG_FILE"

# Install security updates only (safer approach)
log "Installing security updates..."
if sudo unattended-upgrade -d; then
    log "Security updates installed successfully"
else
    log "WARNING: Some security updates may have failed"
fi

# Alternative: Install all updates (uncomment if needed)
# log "Installing all available updates..."
# if sudo apt upgrade -y; then
#     log "All updates installed successfully"
# else
#     log "WARNING: Some updates may have failed"
# fi

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    log "Reboot required after updates"
    log "Reboot reason: $(cat /var/run/reboot-required.pkgs 2>/dev/null || echo 'Unknown')"

    # Schedule reboot in 5 minutes (gives time for script to complete)
    log "Scheduling reboot in 5 minutes..."
    sudo shutdown -r +5 "System reboot required after security updates"
else
    log "No reboot required"
fi

# Post-patch system info
log "Post-patch system info:"
log "Kernel: $(uname -r)"
log "Services needing restart: $(sudo needs-restarting -s 2>/dev/null | wc -l || echo 'N/A')"

# Clean up
log "Cleaning up package cache..."
sudo apt autoremove -y
sudo apt autoclean

log "Patch management process completed"

# Send status to Azure Arc (optional)
if command -v azcmagent &> /dev/null; then
    log "Reporting status to Azure Arc..."
    sudo azcmagent show | grep -E "(Agent Status|Agent Last Heartbeat)" >> "$LOG_FILE"
fi

exit 0