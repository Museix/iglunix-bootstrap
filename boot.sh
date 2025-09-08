#!/bin/sh -e

if [ -z "$1" ]; then
	export ARCH=$(uname -m)
else
	export ARCH=$1
fi

export LLVM_VER=21.1.0
export MUSL_VER=1.2.5
export KERN_VER=6.12.44
export MKSH_VER=R59c
export BUSYBOX_VER=1.37.0
export TOYBOX_VER=0.8.12
export BMAKE_VER=20250804
export OPENSSL_VER=3.5.2
export ZLIB_NG_VER=2.2.2
export CURL_VER=8.15.0
export NCURSES_VER=6.5
export LIBARCHIVE_VER=3.8.1
export BYACC_VER=20240109
export SAMURAI_VER=1.2
export LIBEXECINFO_VER=1.1.0.13
export LIBICONV_VER=1.17
export LIBMD_VER=1.1.0
export FTS_VER=1.2.8
export LIBBSD_VER=0.12.2
export OPENPAM_VER=20250531
export DOAS_VER=6.8.2
export PKGCONF_VER=2.3.0
export OM4_VER=0.0.1
export FLEX_VER=2.6.4
export CMAKE_VER=3.28.3
export XBPS_VER=0.60.5
export GIT_VER=2.51.0
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

./00-fetch.sh

./01-linux-headers.sh

./02-musl-headers.sh

./03-compiler-rt.sh

sudo cp $SYSROOT/usr/lib/clang/21/lib/linux/* $(clang -print-resource-dir)/lib/linux

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

./13-dirs.sh

./14-etc.sh

# Build bmake
./15-bmake.sh

./16-openssl-stage1.sh

./17-zlib.sh

./18-openssl.sh

./19-ncurses.sh

./20-curl.sh

./21-libarchive.sh

./22-xbps.sh

./23-byacc.sh

./24-samurai.sh

./25-libexecinfo.sh
./26-libiconv.sh
./27-libmd.sh
./28-musl-fts.sh
./29-libbsd.sh
./30-openpam.sh
./31-doas.sh
./32-pkgconf.sh
./33-m4.sh
./34-flex.sh
export CC="/usr/bin/musl-clang"
export CXX="/usr/bin/musl-clang++"
./31-gettext-tiny.sh
./34-perl.sh
./35-cmake.sh
./36-git.sh