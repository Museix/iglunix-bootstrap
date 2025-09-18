#!/bin/sh -e
[ -f "$REPO_ROOT/.pkgconf" ] && exit 0

PKGCONF_SRC="$SOURCES/pkgconf-$PKGCONF_VER"
PKGCONF_BUILD="$BUILD/pkgconf"

echo "Building pkgconf $PKGCONF_VER..."

# Create build directory
mkdir -p "$PKGCONF_BUILD"
cd "$PKGCONF_BUILD"

# Configure
"$PKGCONF_SRC/configure" \
    --host="$TARGET" \
    --prefix=/usr \
    --with-sysroot="$SYSROOT" \
    --disable-host-tool \
    --with-pkg-config-dir="/usr/lib/pkgconfig:/usr/share/pkgconfig" \
    --with-system-include-path="/usr/include" \
    --with-system-library-path="/usr/lib"

# Build
make

# Install
make DESTDIR="$SYSROOT" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.pkgconf"
