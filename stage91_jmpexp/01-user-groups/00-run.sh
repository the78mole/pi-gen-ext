#!/bin/bash -e

# Add first user to disk group for device access
on_chroot << EOF
usermod -a -G disk ${FIRST_USER_NAME}
EOF

echo "Added ${FIRST_USER_NAME} to disk group"
