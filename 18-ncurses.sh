#!/bin/sh -e
[ -f "$REPO_ROOT/.ncurses" ] && exit 0

NCURSES_VER=6.5
NCURSES_SRC="$SOURCES/ncurses-$NCURSES_VER"
NCURSES_BUILD="$BUILD/ncurses-$NCURSES_VER"

echo "Building ncurses $NCURSES_VER..."

# Create build directory
mkdir -p "$NCURSES_BUILD"
cd "$NCURSES_BUILD"

# Configure and build
"$NCURSES_SRC/configure" \
    --prefix=/usr \
    --host=$TARGET \
    --with-shared \
    --without-debug \
    --with-sysroot="$SYSROOT" \
    --with-sysroot-include="$SYSROOT/usr/include" \
    --with-sysroot-lib="$SYSROOT/usr/lib" \
    --without-ada \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib/pkgconfig \
    CC="$CC" \
    CFLAGS="$CFLAGS -fPIC" \
    CXXFLAGS="$CXXFLAGS -fPIC" \
    LDFLAGS="$LDFLAGS"

make -j$(nproc)

# Install to sysroot
make DESTDIR="$SYSROOT" install

# Create non-wide character libraries for compatibility
for lib in ncurses form panel menu; do
    ln -sfv ${lib}w.pc $SYSROOT/usr/lib/pkgconfig/${lib}.pc
    ln -sfv lib${lib}w.a $SYSROOT/usr/lib/lib${lib}.a
    ln -sfv lib${lib}w.so $SYSROOT/usr/lib/lib${lib}.so
    ln -sfv lib${lib}w.so.6 $SYSROOT/usr/lib/lib${lib}.so.6
    ln -sfv lib${lib}w.so.6.5 $SYSROOT/usr/lib/lib${lib}.so.6.5
done

# Create version file to prevent recompilation
touch "$REPO_ROOT/.ncurses"