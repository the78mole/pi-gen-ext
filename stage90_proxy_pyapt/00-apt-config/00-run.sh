#!/bin/bash -e

# Skip if ARTIFACTORY_APT_URL is not set
if [ -z "${ARTIFACTORY_APT_URL}" ]; then
	echo "ARTIFACTORY_APT_URL not set, skipping Artifactory APT configuration"
	exit 0
fi

# Extract hostname from URL for machine auth
ARTIFACTORY_HOST=$(echo "${ARTIFACTORY_APT_URL}" | sed -E 's|https?://([^/]+).*|\1|')

# Configure APT to use Artifactory Debian mirror
cat > "${ROOTFS_DIR}/etc/apt/sources.list.d/artifactory-debian.sources" << EOF
Types: deb
URIs: ${ARTIFACTORY_APT_URL}
Suites: ${RELEASE} ${RELEASE}-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# Add security repo if URL is provided
if [ -n "${ARTIFACTORY_APT_SECURITY_URL}" ]; then
	cat >> "${ROOTFS_DIR}/etc/apt/sources.list.d/artifactory-debian.sources" << EOF

Types: deb
URIs: ${ARTIFACTORY_APT_SECURITY_URL}
Suites: ${RELEASE}-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
fi

# Configure Raspberry Pi repository if URL is provided
if [ -n "${ARTIFACTORY_RASPI_URL}" ]; then
	cat > "${ROOTFS_DIR}/etc/apt/sources.list.d/artifactory-raspi.sources" << EOF
Types: deb
URIs: ${ARTIFACTORY_RASPI_URL}
Suites: ${RELEASE}
Components: main
Signed-By: /usr/share/keyrings/raspberrypi-archive-keyring.gpg
EOF
fi

# Configure machine authentication if credentials are provided
if [ -n "${ARTIFACTORY_USER}" ] && [ -n "${ARTIFACTORY_TOKEN}" ]; then
	cat > "${ROOTFS_DIR}/etc/apt/auth.conf.d/artifactory.conf" << EOF
machine ${ARTIFACTORY_HOST}
login ${ARTIFACTORY_USER}
password ${ARTIFACTORY_TOKEN}
EOF

	# Set restrictive permissions for auth file
	on_chroot << INNEREOF
chmod 600 /etc/apt/auth.conf.d/artifactory.conf
INNEREOF
fi

# Remove default Debian and Raspi sources to avoid conflicts
rm -f "${ROOTFS_DIR}/etc/apt/sources.list.d/debian.sources"
rm -f "${ROOTFS_DIR}/etc/apt/sources.list.d/debian.sources.disabled"
rm -f "${ROOTFS_DIR}/etc/apt/sources.list.d/raspi.sources"
rm -f "${ROOTFS_DIR}/etc/apt/sources.list.d/raspi.sources.disabled"

# Update apt cache with new sources
on_chroot << EOF
apt-get update
EOF

echo "APT configured to use Artifactory mirror"
