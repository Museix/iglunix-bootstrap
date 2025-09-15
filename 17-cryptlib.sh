#!/bin/sh -e
[ -f "$REPO_ROOT/.cryptlib" ] && exit 0

CRYPTLIB_VER=3.4.8
CRYPTLIB_SRC="$SOURCES/cryptlib-$CRYPTLIB_VER"
CRYPTLIB_BUILD="$BUILD/cryptlib-$CRYPTLIB_VER"

echo "Building cryptlib $CRYPTLIB_VER..."

# Create build directory
mkdir -p "$CRYPTLIB_BUILD"
cd "$CRYPTLIB_BUILD"

# Configure and build
"$CRYPTLIB_SRC/configure" \
    --prefix=/usr \
    --host=$TARGET \
    --enable-shared=yes \
    --enable-static=yes \
    CC="$CC" \
    CFLAGS="$CFLAGS -fPIC" \
    LDFLAGS="$LDFLAGS"

make -j$(nproc)

# Install to sysroot
make DESTDIR="$SYSROOT" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.cryptlib"