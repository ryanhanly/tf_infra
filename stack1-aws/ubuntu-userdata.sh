#!/bin/bash
# ubuntu-userdata.sh - AWS Ubuntu instance initialization

# Update system
apt update -y

# Install basic tools
apt install -y wget curl vim htop

# Configure local mirror repository if available
if [ -n "${mirror_server_ip}" ]; then
    cat > /etc/apt/sources.list.d/local-mirror.list << EOF
# Local Ubuntu mirror configuration
# deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
# deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
# deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
# deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
EOF

    # Create script to switch to local mirror
    cat > /usr/local/bin/use-local-mirror.sh << 'SCRIPT'
#!/bin/bash
# Script to switch to local Ubuntu mirror

echo "Testing connectivity to local mirror..."
if curl -s http://${mirror_server_ip} > /dev/null; then
    echo "Local mirror is accessible. Switching to local repositories..."

    # Backup original sources.list
    cp /etc/apt/sources.list /etc/apt/sources.list.backup

    # Create new sources.list with local mirror
    cat > /etc/apt/sources.list << EOF
# Local Ubuntu Mirror
deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb http://${mirror_server_ip}/ubuntu/archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse

# Fallback to official repos (commented out)
# deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
# deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
# deb http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
# deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
EOF

    # Update package lists
    apt update

    echo "Successfully configured to use local mirror"
    apt list --installed
else
    echo "Local mirror not accessible. Using default repositories."
fi
SCRIPT

    chmod +x /usr/local/bin/use-local-mirror.sh

    # Test and potentially enable local mirror
    /usr/local/bin/use-local-mirror.sh
fi

# Create a simple system info script
cat > /usr/local/bin/system-info.sh << 'INFO'
#!/bin/bash
echo "=== Ubuntu System Information ==="
echo "Hostname: $(hostname)"
echo "Ubuntu Version: $(lsb_release -d)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo ""
echo "Enabled Repositories:"
apt list --installed | head -10
INFO

chmod +x /usr/local/bin/system-info.sh

echo "Ubuntu AWS instance initialization completed" > /var/log/ubuntu-init.log