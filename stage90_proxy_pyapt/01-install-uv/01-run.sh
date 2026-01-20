#!/bin/bash -e

# Install UV systemwide to /usr/local/bin
on_chroot << EOF
export UV_INSTALL_DIR=/usr/local/bin
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify installation
/usr/local/bin/uv --version
EOF

echo "UV successfully installed to /usr/local/bin"
