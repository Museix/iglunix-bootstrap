#!/bin/sh -e
[ -f "$REPO_ROOT/.etc" ] && exit 0
# 14-etc.sh - Install /etc directory structure for Iglunix
# Part of Iglunix bootstrap process

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

# Source directory containing etc files
ETC_SOURCE="$SYSROOT/etc"
ETC_TARGET="$SYSROOT/etc"

log "Installing /etc directory structure..."

# Ensure target directory exists
mkdir -p "$ETC_TARGET"

# Check if source etc directory exists
if [ ! -d "$ETC_SOURCE" ]; then
    error "Source etc directory not found: $ETC_SOURCE"
fi

log "Copying etc files from $ETC_SOURCE to $ETC_TARGET"

# Copy all files and directories from source etc
cp -r "$ETC_SOURCE" "$ETC_TARGET"/

# Create additional directories that might not exist
mkdir -p "$ETC_TARGET"/{init.d,rc.d,cron.d,logrotate.d,sudoers.d}
mkdir -p "$ETC_TARGET"/profile.d
mkdir -p "$ETC_TARGET"/skel

# Set proper permissions for sensitive files
log "Setting proper permissions..."

# Shadow files - readable only by root
if [ -f "$ETC_TARGET/shadow" ]; then
    chmod 600 "$ETC_TARGET/shadow"
fi

if [ -f "$ETC_TARGET/gshadow" ]; then
    chmod 600 "$ETC_TARGET/gshadow"
fi

# Passwd and group files - readable by all
if [ -f "$ETC_TARGET/passwd" ]; then
    chmod 644 "$ETC_TARGET/passwd"
fi

if [ -f "$ETC_TARGET/group" ]; then
    chmod 644 "$ETC_TARGET/group"
fi

# Hosts file
if [ -f "$ETC_TARGET/hosts" ]; then
    chmod 644 "$ETC_TARGET/hosts"
fi

# Profile files
if [ -f "$ETC_TARGET/profile" ]; then
    chmod 644 "$ETC_TARGET/profile"
fi

# Skel directory
if [ -d "$ETC_TARGET/skel" ]; then
    chmod 755 "$ETC_TARGET/skel"
    # Set permissions for skel files
    find "$ETC_TARGET/skel" -type f -exec chmod 644 {} \;
fi

# Profile.d directory
if [ -d "$ETC_TARGET/profile.d" ]; then
    chmod 755 "$ETC_TARGET/profile.d"
    find "$ETC_TARGET/profile.d" -name "*.sh" -exec chmod 644 {} \;
    find "$ETC_TARGET/profile.d" -name "*.mksh" -exec chmod 644 {} \;
fi

# System configuration files
for file in fstab hostname hosts resolv.conf nsswitch.conf services protocols; do
    if [ -f "$ETC_TARGET/$file" ]; then
        chmod 644 "$ETC_TARGET/$file"
    fi
done

# Security-sensitive files
for file in securetty login.defs; do
    if [ -f "$ETC_TARGET/$file" ]; then
        chmod 600 "$ETC_TARGET/$file"
    fi
done

# Make shells file readable
if [ -f "$ETC_TARGET/shells" ]; then
    chmod 644 "$ETC_TARGET/shells"
fi

log "Creating additional required directories..."

# Create mount points for special filesystems
mkdir -p "$ETC_TARGET"/../{proc,sys,dev}

# Create log directory structure
mkdir -p "$ETC_TARGET"/../var/log
touch $REPO_ROOT/.etc
log "/etc directory structure installed successfully"
log "Files copied from: $ETC_SOURCE"
log "Installed to: $ETC_TARGET"
