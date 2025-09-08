#!/bin/sh -e
[ -f "$REPO_ROOT/.libbsd" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading libbsd source'
cd $SOURCES
wget -c https://libbsd.freedesktop.org/releases/libbsd-$LIBBSD_VER.tar.xz
tar xf libbsd-$LIBBSD_VER.tar.xz

cd libbsd-$LIBBSD_VER

echo '>>> Configuring libbsd'
# Configure with cross-compilation settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib" \
PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-shared \
    --enable-static \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building libbsd'
make -j$(nproc)

echo '>>> Installing libbsd to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.libbsd

echo '>>> libbsd installed successfully'
