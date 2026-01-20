#!/bin/bash -e

# Add enable_uart=1 to config.txt in [all] section
CONFIG_FILE="${ROOTFS_DIR}/boot/firmware/config.txt"

# Check if enable_uart is already set
if ! grep -q "^enable_uart=" "$CONFIG_FILE"; then
	# Add enable_uart=1 after [all] section
	sed -i '/^\[all\]$/a enable_uart=1' "$CONFIG_FILE"
	echo "Added enable_uart=1 to config.txt"
else
	echo "enable_uart already set in config.txt"
fi
