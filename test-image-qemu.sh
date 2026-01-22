#!/bin/bash
# QEMU Test Script for Raspberry Pi Images
# Usage: ./test-image-qemu.sh <image-file>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <image-file.img>"
    echo "Example: $0 deploy/2026-01-21-raspios-custom-jmpexp.img"
    exit 1
fi

echo "Not yet functional!"
exit 1

IMAGE="$1"

if [ ! -f "$IMAGE" ]; then
    echo "Error: Image file '$IMAGE' not found"
    exit 1
fi

echo "Testing Raspberry Pi Image with QEMU"
echo "Image: $IMAGE"
echo ""
echo "Requirements:"
echo "  - qemu-system-aarch64 must be installed"
echo "  - At least 2GB RAM allocated to QEMU"
echo ""

# Check if qemu is installed
if ! command -v qemu-system-aarch64 &> /dev/null; then
    echo "Error: qemu-system-aarch64 not found"
    echo "Install with: sudo apt install qemu-system-arm"
    exit 1
fi

# Extract kernel and dtb from image
echo "Extracting kernel and DTB from image..."
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Mount boot partition (first partition)
LOOP_DEV=$(sudo losetup -f --show -P "$IMAGE")
trap "sudo losetup -d $LOOP_DEV; rm -rf $TEMP_DIR" EXIT

sudo mkdir -p "$TEMP_DIR/boot"
sudo mount "${LOOP_DEV}p1" "$TEMP_DIR/boot"

# Copy kernel and dtb
if [ -f "$TEMP_DIR/boot/kernel8.img" ]; then
    KERNEL="$TEMP_DIR/kernel8.img"
    sudo cp "$TEMP_DIR/boot/kernel8.img" "$KERNEL"
elif [ -f "$TEMP_DIR/boot/vmlinuz" ]; then
    KERNEL="$TEMP_DIR/vmlinuz"
    sudo cp "$TEMP_DIR/boot/vmlinuz" "$KERNEL"
else
    echo "Error: No suitable kernel found in boot partition"
    sudo umount "$TEMP_DIR/boot"
    exit 1
fi

DTB="$TEMP_DIR/bcm2711-rpi-4-b.dtb"
if [ -f "$TEMP_DIR/boot/bcm2711-rpi-4-b.dtb" ]; then
    sudo cp "$TEMP_DIR/boot/bcm2711-rpi-4-b.dtb" "$DTB"
fi

sudo umount "$TEMP_DIR/boot"

echo ""
echo "Starting QEMU..."
echo "Press Ctrl-A then X to exit"
echo ""

# Run QEMU
sudo qemu-system-aarch64 \
    -machine raspi3b \
    -cpu cortex-a72 \
    -smp 4 \
    -m 1G \
    -kernel "$KERNEL" \
    -dtb "$DTB" \
    -drive file="$IMAGE",format=raw,if=sd \
    -append "root=/dev/mmcblk0p2 rw rootwait console=ttyAMA0" \
    -nographic
