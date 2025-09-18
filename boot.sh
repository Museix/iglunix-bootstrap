#!/bin/sh -e

# This script demonstrates how to detect an available sudo-like command
# and re-execute itself with elevated privileges if needed.

# --- Constants ---
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
FULL_SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# --- Helper Functions ---
die() {
    echo "${SCRIPT_NAME}: $*" >&2
    exit 1
}

# --- Privilege Escalation Check ---

# Check if the script is running as root.
if [ "$(id -u)" -eq 0 ]; then
    # Already root, verify we can write to required directories
    : # Continue with the script
else
    # Not root, try to find a privilege escalation command
    SUDO_CMD=""
    
    # Check for sudo with keep environment flag
    if command -v sudo >/dev/null 2>&1; then
        if sudo -n true 2>/dev/null; then
            SUDO_CMD="sudo -E"  # -E preserves environment
        else
            SUDO_CMD="sudo"
        fi
    # Fall back to doas if sudo is not available
    elif command -v doas >/dev/null 2>&1; then
        SUDO_CMD="doas"
    fi

    # If we found a command, re-execute the script with it
    if [ -n "$SUDO_CMD" ]; then
        echo "${SCRIPT_NAME}: This script needs root privileges. Re-executing with '$SUDO_CMD'..."
        # Use exec to replace current process, preserving all arguments and environment
        exec $SUDO_CMD "$FULL_SCRIPT_PATH" "$@"
    else
        die "This script must be run as root. No privilege escalation command (sudo/doas) available."
    fi
fi

# Verify we're running as root after privilege escalation
if [ "$(id -u)" -ne 0 ]; then
    die "Failed to gain root privileges. Current UID: $(id -u)"
fi

# --- Main Script Logic ---

# From this point onwards, the script is running with root privileges.
echo "Running with root privileges (UID: $(id -u))"
[ -f $REPO_ROOT/.update ] && rm -rf .update .muslpatched .uutilspatched src build
# Clean up build markers if a rebuild is requested
[ -f "$REPO_ROOT/.buildagain" ] && rm -rf "$REPO_ROOT/.buildagain" $REPO_ROOT/."{busybox,compiler-rt,cryptlib,curl,dash,etc,libatomic,libcxx,libedit,libexecinfo,libgcc,libunwind,linux-headers,llvm,make,mksh,musl,musl-headers,ncurses,oniguruma,openssl,pkgconf,rust,sqlite,tblgen,toybox,util-linux,uutils,uutilspatched,zlib-ng}" "$REPO_ROOT/build" "$REPO_ROOT/sanity" "$REPO_ROOT/sysroot"
if [ -z "$1" ]; then
	ARCH=`uname -m`
	export ARCH
else
	ARCH="$1"
	export ARCH
fi
log() {
    echo "\033[0;32m[INFO]\033[0m $1"
}
export log
warn() {
    echo "\033[1;33m[WARN]\033[0m $1"
}
export warn
error() {
    echo "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}
export error

export LLVM_VER=21.1.1
export MUSL_VER=1.2.5
export KERN_VER=6.12.47
export GMAKE_VER=4.4.1
export ZLIB_NG_VER=2.2.5
export OPENSSL_VER=3.5.2
export CRYPTLIB_VER=3.4.8
export NCURSES_VER=6.5
export LIBEDIT_VER=2004
export ONIGURUMA_VER=6.9.10
export RUST_VER=1.89.0
export UUTILS_VER=0.2.2
export UTIL_LINUX_VER=2.41.1
export DASH_VER=0.5.12
export LIBEXECINFO_VER=1.1.0.13
export PKGCONF_VER=2.5.1
export LIBPSL_VER=0.21.5
export LIBUNISTRING_VER=1.1
export SQLITE_VER=3.50.4
export SQLITE_VER_CODE=3500400
export AEE_VER=2.2.25

export TARGET=$ARCH-linux-musl

# Get absolute path in POSIX-compliant way
REPO_ROOT=`cd \`dirname "$0"\` && pwd`
export REPO_ROOT
SOURCES="$REPO_ROOT/src"
BUILD="$REPO_ROOT/build"
SYSROOT="$REPO_ROOT/sysroot"
export SOURCES BUILD SYSROOT

COMMON_FLAGS="-O2 -pipe -fpie -fpic --sysroot=$SYSROOT -unwindlib=libunwind"

# because ubuntu uses old llvm (14) we need to pass -mno-relax still
if [ "$ARCH" = "riscv64" ]; then
	COMMON_FLAGS="$COMMON_FLAGS -mno-relax"
fi
RUSTFLAGS="-C link-arg=-fuse-ld=lld -C link-arg=--sysroot=$SYSROOT"
export RUSTFLAGS
CFLAGS="$COMMON_FLAGS"
CXXFLAGS="$COMMON_FLAGS -stdlib=libc++"
LDFLAGS="$COMMON_FLAGS -fuse-ld=lld -rtlib=compiler-rt"
export CFLAGS CXXFLAGS LDFLAGS

CC=/usr/bin/clang
CXX=/usr/bin/clang++
export CC CXX

AR=llvm-ar
RANLIB=llvm-ranlib
export AR RANLIB

if [ -z "$MAKE" ]; then
	MAKE=make
	export MAKE
fi

mkdir -p "$SOURCES"
mkdir -p "$BUILD"
mkdir -p "$SYSROOT"

mkdir -p "$SYSROOT/usr/bin"
mkdir -p "$SYSROOT/usr/lib"
mkdir -p "$SYSROOT/var"
mkdir -p "$SYSROOT/opt"
mkdir -p "$SYSROOT/srv"
mkdir -p "$SYSROOT/mnt"
mkdir -p "$SYSROOT/media"
mkdir -p "$SYSROOT/usr/sbin"
mkdir -p "$SYSROOT/usr/share"
mkdir -p "$SYSROOT/usr/include"
mkdir -p "$SYSROOT/usr/src"
mkdir -p "$SYSROOT/usr/local"
mkdir -p "$SYSROOT/usr/local/sbin"
mkdir -p "$SYSROOT/usr/local/share"
mkdir -p "$SYSROOT/usr/local/include"

# Variable data directories
mkdir -p "$SYSROOT/var/log"
mkdir -p "$SYSROOT/var/tmp"
mkdir -p "$SYSROOT/var/cache"
mkdir -p "$SYSROOT/var/lib"
mkdir -p "$SYSROOT/var/spool"
mkdir -p "$SYSROOT/var/run"
mkdir -p "$SYSROOT/var/lock"
mkdir -p "$SYSROOT/var/lib/misc"
mkdir -p "$SYSROOT/var/lib/locate"
mkdir -p "$SYSROOT/var/spool/mail"
mkdir -p "$SYSROOT/var/spool/cron"

# Temporary directories
mkdir -p "$SYSROOT/tmp"
chmod 1777 "$SYSROOT/tmp"

# Device and system directories
mkdir -p "$SYSROOT/dev"
mkdir -p "$SYSROOT/proc"
mkdir -p "$SYSROOT/sys"
mkdir -p "$SYSROOT/run"

# Home directories
mkdir -p "$SYSROOT/home"
mkdir -p "$SYSROOT/root"
chmod 700 "$SYSROOT"/root

# Boot directory
mkdir -p "$SYSROOT"/boot

# Configuration directory (will be populated by 14-etc.sh)
mkdir -p "$SYSROOT"/etc

# Create symlinks for compatibility
log "Creating compatibility symlinks..."

# Create lib, lib64, and usr/lib64 as symlinks to usr/lib
ln -sf usr/lib  "$SYSROOT"/lib
ln -sf usr/lib  "$SYSROOT"/lib64
ln -sf lib      "$SYSROOT"/usr/lib64
ln -sf usr/bin  "$SYSROOT"/bin
ln -sf usr/sbin "$SYSROOT"/sbin 

# Create /usr/lib/locale for locale support
mkdir -p "$SYSROOT"/usr/lib/locale

# Set proper permissions
log "Setting directory permissions..."
chmod 755 "$SYSROOT/bin"
chmod 755 "$SYSROOT/sbin"
chmod 755 "$SYSROOT/usr"
chmod 755 "$SYSROOT/var"
chmod 755 "$SYSROOT/opt"
chmod 755 "$SYSROOT/srv"
chmod 755 "$SYSROOT/mnt"
chmod 755 "$SYSROOT/media"
chmod 755 "$SYSROOT/usr/bin"
chmod 755 "$SYSROOT/usr/sbin"
chmod 755 "$SYSROOT/usr/lib"
chmod 755 "$SYSROOT/usr/share"
chmod 755 "$SYSROOT/usr/include"
chmod 755 "$SYSROOT/usr/src"
chmod 755 "$SYSROOT/usr/local"
chmod 755 "$SYSROOT/var/log"
chmod 755 "$SYSROOT/var/cache"
chmod 755 "$SYSROOT/var/lib"
chmod 755 "$SYSROOT/var/spool"
chmod 1777 "$SYSROOT/var/tmp"
chmod 755 "$SYSROOT/var/run"
chmod 755 "$SYSROOT/var/lock"

./00-fetch.sh

./01-linux-headers.sh

./02-musl-headers.sh

./03-compiler-rt.sh

# Create target directory if it doesn't exist
mkdir -p "$SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux"

# Only try to copy if there are files to copy
if [ -d "$SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux" ] && [ "$(ls -A $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux 2>/dev/null)" ]; then
    # Try to copy to system clang's resource directory if it exists
    if [ -d "$(clang -print-resource-dir 2>/dev/null)/lib/linux" ]; then
        sudo cp $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux/* "$(clang -print-resource-dir 2>/dev/null)/lib/linux/" || true
    fi
    
    # Also try with full path to clang
    if [ -d "$(/usr/bin/clang -print-resource-dir 2>/dev/null)/lib/linux" ]; then
        sudo cp $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux/* "$(/usr/bin/clang -print-resource-dir 2>/dev/null)/lib/linux/" || true
    fi
fi

./04-musl.sh

# export COMMON_FLAGS="-O2 -pipe --sysroot=$SYSROOT -unwindlib=libunwind -v"

# export CFLAGS="${COMMON_FLAGS}"
# export CXXFLAGS="${COMMON_FLAGS} -stdlib=libc++"
# export LDFLAGS="-fuse-ld=lld -rtlib=compiler-rt -resource-dir=$SYSROOT"

./05-libunwind.sh

./09-libatomic.sh

./06-libcxx.sh

./07-sanity.sh

# Only try to copy if there are files to copy
if [ -d "$SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux" ] && [ "$(ls -A $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux 2>/dev/null)" ]; then
    # Try to copy to system clang's resource directory if it exists
    if [ -d "$(clang -print-resource-dir 2>/dev/null)/lib/linux" ]; then
        sudo cp -f $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux/* "$(clang -print-resource-dir 2>/dev/null)/lib/linux/" || true
    fi
    
    # Also try with full path to clang
    if [ -d "$(/usr/bin/clang -print-resource-dir 2>/dev/null)/lib/linux" ]; then
        sudo cp -f $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux/* "$(/usr/bin/clang -print-resource-dir 2>/dev/null)/lib/linux/" || true
    fi
fi

CC=`pwd`/$ARCH-iglunix-linux-musl-cc.sh
CXX=`pwd`/$ARCH-iglunix-linux-musl-c++.sh
export CC CXX

./08-dash.sh

./10-pkgconfig.sh

./19-oniguruma.sh

# Build libxo, libxml2, and tinygettext
./16-libxo-xml2-tinygettext.sh

./23-curl.sh

./17-libacl-md-bsd.sh

./21-chimerautils.sh

./25-sqlite.sh

./22-util-linux.sh

env -u CFLAGS -u CXXFLAGS -u LDFLAGS ./11-tblgen.sh

./12-llvm.sh

./13-etc.sh

# Build and install GNU Make
./14-gmake.sh

./27-sed.sh

./26-amp.sh

[ -f *.tar.gz ] && touch $REPO_ROOT/.buildagain && rm -f *.tar.gz
tar czf MUSEIX-$ARCH-$(date +%Y%m%d).tar.gz sysroot
chmod 666 MUSEIX-$ARCH-$(date +%Y%m%d).tar.gz
log "chroot archive created: MUSEIX-$ARCH-$(date +%Y%m%d).tar.gz"
