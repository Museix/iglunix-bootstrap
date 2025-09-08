#!/bin/sh
[ -f "$REPO_ROOT/.dirs" ] && exit 0
# 13-dirs.sh - Create directory structure for arch-chroot
# Part of Iglunix bootstrap process

set -e

. ./cfg.sh

log() {
    echo "\033[0;32m[INFO]\033[0m $1"
}

warn() {
    echo "\033[1;33m[WARN]\033[0m $1"
}

error() {
    echo "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}

log "Creating directory structure for arch-chroot..."

# SYSROOT directory is created by boot.sh

# Create essential directories for a functional chroot environment
log "Creating essential system directories..."

# Check if we have write permissions to SYSROOT
SUDO_CMD="sudo"


# Root filesystem structure
$SUDO_CMD mkdir -p "$SYSROOT"/{sbin,lib64,var,opt,srv,mnt,media}
$SUDO_CMD mkdir -p "$SYSROOT"/usr/{sbin,lib64,share,include,src,local}
$SUDO_CMD mkdir -p "$SYSROOT"/usr/local/{sbin,share,include}

# Variable data directories
$SUDO_CMD mkdir -p "$SYSROOT"/var/{log,tmp,cache,lib,spool,run,lock}
$SUDO_CMD mkdir -p "$SYSROOT"/var/lib/{misc,locate}
$SUDO_CMD mkdir -p "$SYSROOT"/var/spool/{mail,cron}

# Temporary directories
$SUDO_CMD mkdir -p "$SYSROOT"/tmp
$SUDO_CMD chmod 1777 "$SYSROOT"/tmp

# Device and system directories
$SUDO_CMD mkdir -p "$SYSROOT"/{dev,proc,sys,run}

# Home directories
$SUDO_CMD mkdir -p "$SYSROOT"/{home,root}
$SUDO_CMD chmod 700 "$SYSROOT"/root

# Boot directory
$SUDO_CMD mkdir -p "$SYSROOT"/boot

# Configuration directory (will be populated by 14-etc.sh)
$SUDO_CMD mkdir -p "$SYSROOT"/etc

# Create symlinks for compatibility
log "Creating compatibility symlinks..."

# lib64 -> lib symlinks for musl compatibility
if [ "$ARCH" = "x86_64" ]; then
    $SUDO_CMD ln -sf lib "$SYSROOT"/lib64
    $SUDO_CMD ln -sf lib "$SYSROOT"/usr/lib64
fi

# Create /usr/lib/locale for locale support
$SUDO_CMD mkdir -p "$SYSROOT"/usr/lib/locale

# Set proper permissions
log "Setting directory permissions..."
$SUDO_CMD chmod 755 "$SYSROOT"/{bin,sbin,lib,usr,var,opt,srv,mnt,media}
$SUDO_CMD chmod 755 "$SYSROOT"/usr/{bin,sbin,lib,share,include,src,local}
$SUDO_CMD chmod 755 "$SYSROOT"/var/{log,cache,lib,spool}
$SUDO_CMD chmod 1777 "$SYSROOT"/var/tmp
$SUDO_CMD chmod 755 "$SYSROOT"/var/run
$SUDO_CMD chmod 755 "$SYSROOT"/var/lock

log "Directory structure created successfully in $SYSROOT"
log "Ready for arch-chroot operations"
touch $REPO_ROOT/.dirs
