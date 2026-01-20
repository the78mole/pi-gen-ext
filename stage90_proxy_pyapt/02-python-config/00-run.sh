#!/bin/bash -e

# Skip if ARTIFACTORY_PYPI_URL is not set
if [ -z "${ARTIFACTORY_PYPI_URL}" ]; then
	echo "ARTIFACTORY_PYPI_URL not set, skipping Artifactory PyPI configuration"
	exit 0
fi

# Configure UV to use Artifactory PyPI mirror
on_chroot << EOF
# Create system-wide environment file for UV
mkdir -p /etc/profile.d
cat > /etc/profile.d/uv-config.sh << INNEREOF
# UV Configuration
export UV_DEFAULT_INDEX="${ARTIFACTORY_PYPI_URL}"
INNEREOF

chmod +x /etc/profile.d/uv-config.sh
EOF

# Configure pip to use Artifactory PyPI mirror
on_chroot << EOF
# Create global pip configuration
mkdir -p /etc/pip.conf.d
cat > /etc/pip.conf.d/artifactory.conf << INNEREOF
[global]
index-url = ${ARTIFACTORY_PYPI_URL}
INNEREOF

# Also create pip.conf in the standard location
mkdir -p /etc
cat > /etc/pip.conf << INNEREOF
[global]
index-url = ${ARTIFACTORY_PYPI_URL}
INNEREOF
EOF

echo "UV and pip configured to use Artifactory PyPI mirror"
