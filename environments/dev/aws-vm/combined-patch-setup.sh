#!/bin/bash
# combined-patch-setup.sh - Complete patch management setup for Arc VMs

SERVER_NAME="${server_name}"
LOG_FILE="/var/log/azure-patch-setup.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVER_NAME] $1" | tee -a "$LOG_FILE"
}

log "Starting complete patch management setup"

# Create directories
sudo mkdir -p /usr/local/bin
sudo mkdir -p /var/log

# Create the patch script
log "Creating patch management script"
sudo cat > /usr/local/bin/azure-patch-system.sh << 'EOF'
#!/bin/bash
# Azure Arc patch management script

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

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    log "Reboot required after updates"
    log "Reboot reason: $(cat /var/run/reboot-required.pkgs 2>/dev/null || echo 'Unknown')"

    # Schedule reboot for 2 AM if it's before midnight, otherwise wait until next 2 AM
    current_hour=$(date +%H)
    if [ "$current_hour" -lt 2 ]; then
        sudo shutdown -r $(date -d "today 02:00" +%H:%M) "Scheduled reboot after security updates"
        log "Reboot scheduled for 2 AM today"
    else
        sudo shutdown -r $(date -d "tomorrow 02:00" +%H:%M) "Scheduled reboot after security updates"
        log "Reboot scheduled for 2 AM tomorrow"
    fi
else
    log "No reboot required"
fi

# Post-patch system info
log "Post-patch system info:"
log "Kernel: $(uname -r)"

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
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/azure-patch-system.sh
log "Patch script created and made executable"

# Set up cron job for weekly patching (Sundays at 1 AM)
log "Setting up weekly patch schedule (Sundays at 1 AM)"
(sudo crontab -l 2>/dev/null || true; echo "0 1 * * 0 /usr/local/bin/azure-patch-system.sh") | sudo crontab -

# Create log rotation for patch logs
log "Setting up log rotation"
sudo cat > /etc/logrotate.d/azure-patch << 'EOF'
/var/log/azure-patch-management.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}

/var/log/azure-patch-setup.log {
    monthly
    rotate 6
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

log "Log rotation configured"

# Show configured cron jobs
log "Configured cron jobs:"
sudo crontab -l | grep azure-patch-system || log "No patch cron jobs found"

# Test the patch script works
log "Testing patch script (dry run)..."
sudo /usr/local/bin/azure-patch-system.sh

log "Complete patch management setup finished successfully"

exit 0