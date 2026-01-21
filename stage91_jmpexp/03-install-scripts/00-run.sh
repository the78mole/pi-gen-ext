#!/bin/bash -e

# Install custom scripts to /usr/local/bin
for script in files/*; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        install -m 755 "$script" "${ROOTFS_DIR}/usr/local/bin/$script_name"
        echo "Installed $script_name to /usr/local/bin"
    fi
done

echo "Custom scripts installed successfully"
