#!/bin/sh -e
[ -f "$REPO_ROOT/.openssl" ] && exit 0
cd $SOURCES/openssl-$OPENSSL_VER

echo '>>> Configuring OpenSSL'
# Configure with musl-compatible settings
./Configure \
    --prefix=/usr \
    --openssldir=/etc/ssl \
    --libdir=lib \
    shared \
    zlib \
    linux-$(uname -m) \
    -fPIE -fPIC \
    -I$SYSROOT/usr/include \
    -L$SYSROOT/usr/lib \
    -Wl,-rpath=$SYSROOT/usr/lib \
    -Wl,--enable-new-dtags \
    -Wl,--as-needed \
    -Wl,-z,now \
    -Wl,-z,relro \
    -Wl,-z,noexecstack \
    -Wl,-O1 \
    -Wl,--hash-style=gnu \
    -Wl,--sort-common \
    -Wl,--strip-all

echo '>>> Building OpenSSL'
make -j$(nproc) depend
make -j$(nproc)

# Install to sysroot
echo '>>> Installing OpenSSL to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install_sw install_ssldirs

# Create version file to prevent recompilation
touch $REPO_ROOT/.openssl