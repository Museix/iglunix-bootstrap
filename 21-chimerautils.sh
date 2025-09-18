#!/bin/sh -e
[ -f "$REPO_ROOT/.chimerautils" ] && exit 0

echo ">>> building chimerautils"

cd "$SOURCES/chimerautils"
rm -rf build
# Ensure build directory exists
mkdir -p build

# Configure with Meson
meson setup build \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --buildtype=release \
    --cross-file "$REPO_ROOT/build-aux/cross/$ARCH-linux-musl.ini" \
    -Dc_std=c99 \
    -Dcpp_rtti=false \
    -Dwarning_level=2 \
    -Dc_link_args="-L$SYSROOT/usr/lib -Wl,-rpath=$SYSROOT/usr/lib -lfts -lobstack -lm" \
    -Dc_args="-I$SYSROOT/usr/include -D_GNU_SOURCE" \
    -Dbzip2=disabled \
    -Dlzma=disabled \
    -Dzstd=disabled \
    -Dpam=disabled \
    -Dselinux=disabled \
    -Dtiny=disabled
sed -i '1i #include <sys/queue.h>' "$SOURCES/chimerautils/src.freebsd/miscutils/script/script.c"
# Build with samu (faster alternative to ninja)
samu -C build

# Install to sysroot
DESTDIR="$SYSROOT" samu -C build install

# Install man pages if they exist
if [ -d "$SOURCES/chimerautils/man" ]; then
    mkdir -p "$SYSROOT/usr/share/man/man1"
    cp -a "$SOURCES/chimerautils/man"/*.1 "$SYSROOT/usr/share/man/man1/" 2>/dev/null || true
    
    mkdir -p "$SYSROOT/usr/share/man/man5"
    cp -a "$SOURCES/chimerautils/man"/*.5 "$SYSROOT/usr/share/man/man5/" 2>/dev/null || true
    
    mkdir -p "$SYSROOT/usr/share/man/man8"
    cp -a "$SOURCES/chimerautils/man"/*.8 "$SYSROOT/usr/share/man/man8/" 2>/dev/null || true
fi

# Create .chimerautils to mark as built
touch "$REPO_ROOT/.chimerautils"
