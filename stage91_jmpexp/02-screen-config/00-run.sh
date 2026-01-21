#!/bin/bash -e

# Install .screenrc for first user
install -m 644 files/screenrc "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.screenrc"

# Set correct ownership in chroot context
on_chroot << EOF
chown ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.screenrc
EOF

echo "Installed .screenrc for ${FIRST_USER_NAME}"
