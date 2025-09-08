#!/bin/sh
# Script to enter the Iglunix sysroot using the best available chroot method

set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Check if SYSROOT is set, otherwise use default
: ${SYSROOT:="$(dirname "$0")/sysroot"}

# Ensure the sysroot exists
if [ ! -d "$SYSROOT" ]; then
    echo "Error: Sysroot directory not found at $SYSROOT"
    exit 1
fi

# Function to set up a basic chroot environment
setup_chroot() {
    echo "Setting up basic chroot environment..."
    
    # Mount necessary filesystems
    for fs in proc sys dev dev/pts dev/shm; do
        mkdir -p "$SYSROOT/$fs"
        mount --bind "/$fs" "$SYSROOT/$fs"
    done
    
    # Copy resolv.conf for network access
    if [ -f "/etc/resolv.conf" ]; then
        cp /etc/resolv.conf "$SYSROOT/etc/resolv.conf"
    fi
}

# Function to clean up chroot environment
cleanup_chroot() {
    echo "Cleaning up chroot environment..."
    
    # Unmount in reverse order
    for fs in dev/pts dev/shm dev sys proc; do
        if mountpoint -q "$SYSROOT/$fs"; then
            umount -l "$SYSROOT/$fs" 2>/dev/null || true
        fi
    done
}

# Try to use arch-chroot if available
if command -v arch-chroot >/dev/null 2>&1; then
    echo "Using arch-chroot..."
    arch-chroot "$SYSROOT" "$@"
    exit $?
fi

# Try to use chimera-chroot if available
if command -v chimera-chroot >/dev/null 2>&1; then
    echo "Using chimera-chroot..."
    chimera-chroot "$SYSROOT" "$@"
    exit $?
fi

# Fall back to manual chroot setup
echo "No specialized chroot tool found, using manual setup..."

# Set up the chroot environment
trap cleanup_chroot EXIT
setup_chroot

# Enter the chroot
chroot "$SYSROOT" "$@"

# Cleanup will be handled by the EXIT trap
