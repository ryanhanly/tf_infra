#!/bin/bash
# rhel-userdata.sh - AWS RHEL instance initialization

# Update system
dnf update -y

# Install basic tools
dnf install -y wget curl vim htop

# Register with Red Hat if credentials provided
if [ -n "${redhat_username}" ] && [ -n "${redhat_password}" ]; then
    echo "Registering with Red Hat Developer subscription..."
    subscription-manager register --username="${redhat_username}" --password="${redhat_password}" --auto-attach

    # Enable standard repositories
    subscription-manager repos --enable rhel-9-for-x86_64-baseos-rpms
    subscription-manager repos --enable rhel-9-for-x86_64-appstream-rpms
    subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms
fi

# Configure local mirror repository if available
if [ -n "${mirror_server_ip}" ]; then
    cat > /etc/yum.repos.d/local-mirror.repo << EOF
# Local RHEL mirror configuration
[rhel-9-baseos-mirror]
name=Red Hat Enterprise Linux 9 - BaseOS (Local Mirror)
baseurl=http://${mirror_server_ip}/rhel/9/BaseOS
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel-9-appstream-mirror]
name=Red Hat Enterprise Linux 9 - AppStream (Local Mirror)
baseurl=http://${mirror_server_ip}/rhel/9/AppStream
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel-8-baseos-mirror]
name=Red Hat Enterprise Linux 8 - BaseOS (Local Mirror)
baseurl=http://${mirror_server_ip}/rhel/8/BaseOS
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel-8-appstream-mirror]
name=Red Hat Enterprise Linux 8 - AppStream (Local Mirror)
baseurl=http://${mirror_server_ip}/rhel/8/AppStream
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF

    # Create script to switch to local mirror
    cat > /usr/local/bin/use-local-mirror.sh << 'SCRIPT'
#!/bin/bash
# Script to switch to local RHEL mirror

echo "Testing connectivity to local mirror..."
if curl -s http://${mirror_server_ip} > /dev/null; then
    echo "Local mirror is accessible. Switching to local repositories..."

    # Enable local mirror repos
    dnf config-manager --enable rhel-9-baseos-mirror rhel-9-appstream-mirror

    # Optionally disable remote repos to force local usage
    # dnf config-manager --disable rhel-9-for-x86_64-baseos-rpms rhel-9-for-x86_64-appstream-rpms

    echo "Successfully configured to use local mirror"
    dnf repolist enabled
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
echo "=== RHEL System Information ==="
echo "Hostname: $(hostname)"
echo "RHEL Version: $(cat /etc/redhat-release)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Subscription Status:"
subscription-manager status
echo ""
echo "Enabled Repositories:"
dnf repolist enabled
INFO

chmod +x /usr/local/bin/system-info.sh

echo "RHEL AWS instance initialization completed" > /var/log/rhel-init.log