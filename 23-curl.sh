#!/bin/sh -e
[ -f "$REPO_ROOT/.curl" ] && exit 0

CURL_VER=8.4.0
CURL_SRC="$SOURCES/curl"

echo "Building curl $CURL_VER..."
cd "$CURL_SRC"
autoreconf -fi
# Configure and build
./configure \
    --prefix=/usr \
    --host=$TARGET \
    --build=x86_64-unknown-linux-gnu \
    --target=$TARGET \
    --enable-static \
    --with-sysroot=$SYSROOT \
    --without-libpsl \
    --with-ssl \
    --with-zlib \
    CFLAGS="-target $TARGET $CFLAGS" \
    CXXFLAGS="-target $TARGET $CXXFLAGS" \
    LDFLAGS="-L$SYSROOT/usr/lib -lc $LDFLAGS" \
    LIBS="-ldl -lpthread"
make -j$(nproc)

# Install to sysroot
make DESTDIR="$SYSROOT" install
extra_args=
if [ ! -e /etc/ssl/cert.pem ]
then
	printf 'WARNING: using insecure protocol for downloading certificates\n'
	extra_args=-k
fi
curl $extra_args -L https://curl.se/ca/cacert-2025-09-09.pem -o $SYSROOT/etc/ssl/cert.pem
# Create version file to prevent recompilation
touch "$REPO_ROOT/.curl"
