#!/bin/bash -e

# Create jumpstarter group if it doesn't exist
on_chroot << EOF
groupadd -f jumpstarter
EOF

# Add first user to disk and jumpstarter groups for device access
on_chroot << EOF
usermod -a -G disk,jumpstarter ${FIRST_USER_NAME}
EOF

echo "Added ${FIRST_USER_NAME} to disk and jumpstarter groups"
