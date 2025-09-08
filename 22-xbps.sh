#!/bin/sh -e
[ -f "$REPO_ROOT/.xbps" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading XBPS source'
cd $SOURCES
wget -c https://github.com/void-linux/xbps/archive/refs/tags/$XBPS_VER.tar.gz
tar xf $XBPS_VER.tar.gz

cd xbps-$XBPS_VER

echo '>>> Configuring XBPS'
# Configure with cross-compilation and musl-compatible settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib -lz -lssl -lcrypto -larchive" \
PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig" \
PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig" \
PKG_CONFIG_SYSROOT_DIR="$SYSROOT" \
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-static \
    --enable-shared \
    --with-openssl \
    --with-zlib \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building XBPS'
make -j$(nproc)

echo '>>> Installing XBPS to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create basic XBPS configuration
echo '>>> Creating XBPS configuration'
$SUDO_CMD mkdir -p $SYSROOT/etc/xbps.d
$SUDO_CMD mkdir -p $SYSROOT/var/db/xbps/keys

# Create basic xbps.conf
$SUDO_CMD tee $SYSROOT/etc/xbps.conf > /dev/null << 'EOF'
# XBPS configuration for Iglunix
architecture=auto
syslog=true
cachedir=/var/cache/xbps
rootdir=/
EOF

# Create version file to prevent recompilation
touch $REPO_ROOT/.xbps

echo '>>> XBPS installed successfully'
