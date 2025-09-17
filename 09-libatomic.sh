#!/bin/sh -e
[ -f "$REPO_ROOT/.libatomic" ] && exit 0

LIBATOMIC_SRC="$SOURCES/libatomic"

echo "Building libatomic..."

# Create build directory
cd "$LIBATOMIC_SRC"

# Build
make \
    CC="$CC" \
    CFLAGS="-target $TARGET $CFLAGS -fPIC" \
    LDFLAGS="-target $TARGET $LDFLAGS" \
    PREFIX=/usr all

# Install to sysroot
make -f "$LIBATOMIC_SRC/Makefile" PREFIX=/usr all  DESTDIR="$SYSROOT" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.libatomic"
