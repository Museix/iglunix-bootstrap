#!/bin/sh -e
[ -f "$REPO_ROOT/.libarchive" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading libarchive source'
cd $SOURCES
wget -c https://github.com/libarchive/libarchive/releases/download/v$LIBARCHIVE_VER/libarchive-$LIBARCHIVE_VER.tar.gz
tar xf libarchive-$LIBARCHIVE_VER.tar.gz

cd libarchive-$LIBARCHIVE_VER

echo '>>> Configuring libarchive'
# Configure with cross-compilation and musl-compatible settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib" \
PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-shared \
    --enable-static \
    --with-zlib \
    --with-openssl \
    --without-xml2 \
    --without-expat \
    --without-nettle \
    --without-lzo2 \
    --without-lzma \
    --without-bz2lib \
    --build=$(./build/autoconf/config.guess) \
    --host=$TARGET

echo '>>> Building libarchive'
make -j$(nproc)

echo '>>> Installing libarchive to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.libarchive

echo '>>> libarchive installed successfully'
