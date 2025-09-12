#!/bin/sh -e

if [ -z "$1" ]; then
	export ARCH=$(uname -m)
else
	export ARCH=$1
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

export LLVM_VER=16.0.0
export MUSL_VER=1.2.3
export KERN_VER=6.2.7
export MKSH_VER=R59c
export BUSYBOX_VER=1.36.0
export TOYBOX_VER=0.8.9

export TARGET=$ARCH-linux-musl

export REPO_ROOT=$(realpath $(dirname $0))
export SOURCES="$REPO_ROOT/src"
export BUILD="$REPO_ROOT/build"
export SYSROOT="$REPO_ROOT/sysroot"

export COMMON_FLAGS="-O2 -pipe --sysroot=$SYSROOT -unwindlib=libunwind"

# because ubuntu uses old llvm (14) we need to pass -mno-relax still
if [ "$ARCH" = "riscv64" ]; then
	export COMMON_FLAGS="$COMMON_FLAGS -mno-relax"
fi

export CFLAGS="${COMMON_FLAGS}"
export CXXFLAGS="${COMMON_FLAGS} -stdlib=libc++"
export LDFLAGS="-fuse-ld=lld -rtlib=compiler-rt"

export CC=clang
export CXX=clang++

export AR=llvm-ar
export RANLIB=llvm-ranlib

[ -z "$MAKE" ] && export MAKE=make

mkdir -p "$SOURCES"
mkdir -p "$BUILD"
mkdir -p "$SYSROOT"

mkdir -p "$SYSROOT/usr/bin"
mkdir -p "$SYSROOT/usr/lib"
mkdir -p "$SYSROOT/bin"
mkdir -p "$SYSROOT/lib"
mkdir -p "$SYSROOT"/{sbin,lib64,var,opt,srv,mnt,media}
mkdir -p "$SYSROOT"/usr/{sbin,lib64,share,include,src,local}
mkdir -p "$SYSROOT"/usr/local/{sbin,share,include}

# Variable data directories
mkdir -p "$SYSROOT"/var/{log,tmp,cache,lib,spool,run,lock}
mkdir -p "$SYSROOT"/var/lib/{misc,locate}
mkdir -p "$SYSROOT"/var/spool/{mail,cron}

# Temporary directories
mkdir -p "$SYSROOT"/tmp
chmod 1777 "$SYSROOT"/tmp

# Device and system directories
mkdir -p "$SYSROOT"/{dev,proc,sys,run}

# Home directories
mkdir -p "$SYSROOT"/{home,root}
chmod 700 "$SYSROOT"/root

# Boot directory
mkdir -p "$SYSROOT"/boot

# Configuration directory (will be populated by 14-etc.sh)
mkdir -p "$SYSROOT"/etc

# Create symlinks for compatibility
log "Creating compatibility symlinks..."

# lib64 -> lib symlinks for musl compatibility
if [ "$ARCH" = "x86_64" ]; then
     ln -sf lib "$SYSROOT"/lib64
     ln -sf /usr/lib "$SYSROOT"/usr/lib64
fi

# Create /usr/lib/locale for locale support
mkdir -p "$SYSROOT"/usr/lib/locale

# Set proper permissions
log "Setting directory permissions..."
chmod 755 "$SYSROOT"/{bin,sbin,lib,usr,var,opt,srv,mnt,media}
chmod 755 "$SYSROOT"/usr/{bin,sbin,lib,share,include,src,local}
chmod 755 "$SYSROOT"/var/{log,cache,lib,spool}
chmod 1777 "$SYSROOT"/var/tmp
chmod 755 "$SYSROOT"/var/run
chmod 755 "$SYSROOT"/var/lock

./00-fetch.sh

./01-linux-headers.sh

./02-musl-headers.sh

./03-compiler-rt.sh

sudo cp $SYSROOT/usr/lib/clang/16/lib/linux/* $(clang -print-resource-dir)/lib/linux

./04-musl.sh

# export COMMON_FLAGS="-O2 -pipe --sysroot=$SYSROOT -unwindlib=libunwind -v"

# export CFLAGS="${COMMON_FLAGS}"
# export CXXFLAGS="${COMMON_FLAGS} -stdlib=libc++"
# export LDFLAGS="-fuse-ld=lld -rtlib=compiler-rt -resource-dir=$SYSROOT"

./05-libunwind.sh

./06-libcxx.sh

./07-sanity.sh

export CC=$(pwd)/$ARCH-iglunix-linux-musl-cc.sh
export CXX=$(pwd)/$ARCH-iglunix-linux-musl-c++.sh

./08-mksh.sh

./09-busybox.sh

./10-toybox.sh

env -u CFLAGS -u CXXFLAGS -u LDFLAGS ./11-tblgen.sh

./12-llvm.sh

./13-etc.sh
