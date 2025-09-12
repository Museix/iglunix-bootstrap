#!/bin/sh -e

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

warn() {
    echo "\033[1;33m[WARN]\033[0m $1"
}

error() {
    echo "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}

export LLVM_VER=21.1.0
export MUSL_VER=1.2.5
export KERN_VER=6.2.47
export MKSH_VER=R59c
export BUSYBOX_VER=1.37.0
export TOYBOX_VER=0.8.12

export TARGET=$ARCH-linux-musl

# Get absolute path in POSIX-compliant way
REPO_ROOT=`cd "\`dirname "$0"\`" && pwd`
export REPO_ROOT
SOURCES="$REPO_ROOT/src"
BUILD="$REPO_ROOT/build"
SYSROOT="$REPO_ROOT/sysroot"
export SOURCES BUILD SYSROOT

COMMON_FLAGS="-O2 -pipe --sysroot=$SYSROOT -unwindlib=libunwind"

# because ubuntu uses old llvm (14) we need to pass -mno-relax still
if [ "$ARCH" = "riscv64" ]; then
	COMMON_FLAGS="$COMMON_FLAGS -mno-relax"
fi

CFLAGS="$COMMON_FLAGS"
CXXFLAGS="$COMMON_FLAGS -stdlib=libc++"
LDFLAGS="-fuse-ld=lld -rtlib=compiler-rt"
export CFLAGS CXXFLAGS LDFLAGS

CC=clang
CXX=clang++
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
mkdir -p "$SYSROOT/bin"
mkdir -p "$SYSROOT/sbin"
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
ln -sf usr/lib "$SYSROOT"/lib
ln -sf usr/lib "$SYSROOT"/lib64
ln -sf lib "$SYSROOT"/usr/lib64

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

sudo cp $SYSROOT/usr/lib/clang/$LLVM_VER/lib/linux/* `clang -print-resource-dir`/lib/linux

./04-musl.sh

# export COMMON_FLAGS="-O2 -pipe --sysroot=$SYSROOT -unwindlib=libunwind -v"

# export CFLAGS="${COMMON_FLAGS}"
# export CXXFLAGS="${COMMON_FLAGS} -stdlib=libc++"
# export LDFLAGS="-fuse-ld=lld -rtlib=compiler-rt -resource-dir=$SYSROOT"

./05-libunwind.sh

./06-libcxx.sh

./07-sanity.sh

CC=`pwd`/$ARCH-iglunix-linux-musl-cc.sh
CXX=`pwd`/$ARCH-iglunix-linux-musl-c++.sh
export CC CXX

./08-mksh.sh

./09-busybox.sh

./10-toybox.sh

env -u CFLAGS -u CXXFLAGS -u LDFLAGS ./11-tblgen.sh

./12-llvm.sh

./13-etc.sh
