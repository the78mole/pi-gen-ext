#!/bin/bash -e

# Create jumpstarter group
on_chroot << EOF
groupadd -f jumpstarter
EOF

echo "Created jumpstarter group"

# Create /etc/jumpstarter directory structure
install -d -m 775 "${ROOTFS_DIR}/etc/jumpstarter"
install -d -m 775 "${ROOTFS_DIR}/etc/jumpstarter/exporters"

# Install example exporter config
install -m 664 files/jmp-example-local.yaml "${ROOTFS_DIR}/etc/jumpstarter/exporters/jmp-example-local.yaml"

# Set ownership in chroot context
on_chroot << EOF
chgrp -R jumpstarter /etc/jumpstarter
EOF

echo "Installed jumpstarter configuration to /etc/jumpstarter/exporters"
