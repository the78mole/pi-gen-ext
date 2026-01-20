#!/bin/bash -e

# Install jumpstarter-cli with jumpstarter-all (includes all drivers, admin-cli, exporter)
# jumpstarter-all is a meta-package without executables, so we install cli with it
BASE_INSTALL_CMD="jumpstarter-cli --with jumpstarter-all"

# Additional required packages
REQUIRED_PACKAGES="usbsdmux sdwire"

# Build additional packages list from config if set
EXTRA_PACKAGES=""
if [ -n "${JMPEXP_EXTRA_PACKAGES}" ]; then
	EXTRA_PACKAGES="${JMPEXP_EXTRA_PACKAGES}"
fi

echo "Installing jumpstarter with command: uv tool install ${BASE_INSTALL_CMD}"
echo "Required packages: ${REQUIRED_PACKAGES}"
if [ -n "${EXTRA_PACKAGES}" ]; then
	echo "Additional packages: ${EXTRA_PACKAGES}"
fi

# Install packages using uv tool install as the first user
on_chroot << EOF
# Switch to first user and install packages
su - ${FIRST_USER_NAME} << 'USEREOF'
# Ensure PATH includes uv
export PATH=/usr/local/bin:\$PATH

# Install jumpstarter-cli with jumpstarter-all
echo "Installing jumpstarter-cli with jumpstarter-all..."
uv tool install ${BASE_INSTALL_CMD}

# Install required packages
for package in ${REQUIRED_PACKAGES}; do
	echo "Installing \$package..."
	uv tool install "\$package"
done

# Install any additional packages
if [ -n "${EXTRA_PACKAGES}" ]; then
	for package in ${EXTRA_PACKAGES}; do
		echo "Installing \$package..."
		uv tool install "\$package"
	done
fi

# Verify installation
echo "Installed packages:"
uv tool list
USEREOF
EOF

echo "Jumpstarter packages installed successfully"
