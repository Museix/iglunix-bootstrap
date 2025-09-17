#!/bin/sh -e
[ -f "$REPO_ROOT/.cryptlib" ] && exit 0

CRYPTLIB_VER=3.4.8
CRYPTLIB_SRC="$SOURCES/cryptlib-$CRYPTLIB_VER/cryptlib-$CRYPTLIB_VER"
CRYPTLIB_BUILD="$BUILD/cryptlib-$CRYPTLIB_VER"

echo "Building cryptlib $CRYPTLIB_VER..."

# Create build directory
cd "$CRYPTLIB_SRC"

# Configure and build

make DESTDIR="$SYSROOT" -j$(nproc)

# Install to sysroot
make DESTDIR="$SYSROOT" PREFIX="/usr" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.cryptlib"