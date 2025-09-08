#!/bin/sh -e
[ -f "$REPO_ROOT/.curl" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading curl source'
cd $SOURCES
wget -c https://curl.se/download/curl-$CURL_VER.tar.gz
tar xf curl-$CURL_VER.tar.gz

cd curl-$CURL_VER

echo '>>> Configuring curl'
# Configure with OpenSSL, zlib-ng, and cross-compilation support
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
    --mandir=/usr/share/man \
    --enable-shared \
    --disable-static \
    --with-openssl \
    --with-zlib \
    --enable-ipv6 \
    --enable-unix-sockets \
    --disable-ldap \
    --disable-ldaps \
    --without-librtmp \
    --without-libssh2 \
    --without-libpsl \
    --without-brotli \
    --without-nghttp2 \
    --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building curl'
make -j$(nproc)

echo '>>> Installing curl to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.curl

echo '>>> curl installed successfully'
