#!/bin/bash
# setup-cron.sh - Set up scheduled patching for Arc VMs

SERVER_NAME="${server_name}"
LOG_FILE="/var/log/azure-patch-setup.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVER_NAME] $1" | tee -a "$LOG_FILE"
}

log "Setting up scheduled patch management"

# Create the patch script in a standard location
sudo mkdir -p /usr/local/bin
sudo cat > /usr/local/bin/azure-patch-system.sh << 'EOF'
#!/bin/bash
# Azure Arc patch management script

LOG_FILE="/var/log/azure-patch-management.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SCHEDULED] $1" | tee -a "$LOG_FILE"
}

log "Starting scheduled patch management"

# Update package lists
log "Updating package lists..."
sudo apt update >> "$LOG_FILE" 2>&1

# Install security updates only
log "Installing security updates..."
sudo unattended-upgrade -d >> "$LOG_FILE" 2>&1

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    log "Reboot required after updates"
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

# Clean up
sudo apt autoremove -y >> "$LOG_FILE" 2>&1
sudo apt autoclean >> "$LOG_FILE" 2>&1

log "Scheduled patch management completed"
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/azure-patch-system.sh

# Set up cron job for weekly patching (Sundays at 1 AM)
log "Setting up weekly patch schedule (Sundays at 1 AM)"
(sudo crontab -l 2>/dev/null || true; echo "0 1 * * 0 /usr/local/bin/azure-patch-system.sh") | sudo crontab -

# Set up monthly full system update (First Sunday of month at 3 AM)
log "Setting up monthly full update schedule"
(sudo crontab -l 2>/dev/null || true; echo "0 3 1-7 * 0 /usr/local/bin/azure-patch-system.sh") | sudo crontab -

# Create log rotation for patch logs
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
EOF

log "Cron jobs configured:"
sudo crontab -l | grep azure-patch-system || log "No cron jobs found"

log "Patch scheduling setup completed"

# Test the patch script works
log "Testing patch script..."
sudo /usr/local/bin/azure-patch-system.sh

exit 0