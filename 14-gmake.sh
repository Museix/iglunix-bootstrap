#!/bin/sh -e
[ -f "$REPO_ROOT/.make" ] && exit 0
GMAKE_SRC="$SOURCES/make-$GMAKE_VER"
GMAKE_BUILD="$BUILD/make-$GMAKE_VER"
log "Building GNU Make $GMAKE_VER..."

# Create build directory
mkdir -p "$GMAKE_BUILD"
cd "$GMAKE_BUILD"

# Configure and build
"$GMAKE_SRC/configure" \
    --prefix=/usr \
    --host=$TARGET \
    --build=$(sh $GMAKE_SRC/config.guess) \
    --without-guile \
    --disable-nls \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    --with-sysroot="$SYSROOT"

$MAKE -j$(nproc)

# Install to sysroot
$MAKE DESTDIR="$SYSROOT" install

# Create a 'gmake' symlink to maintain compatibility
ln -sf make "$SYSROOT/usr/bin/gmake"

touch "$REPO_ROOT/.make"
