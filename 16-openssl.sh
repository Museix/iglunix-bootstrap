#!/bin/sh -e
[ -f "$REPO_ROOT/.openssl" ] && exit 0

# Check for required tools
for tool in make perl; do
    if ! command -v $tool >/dev/null 2>&1; then
        echo "ERROR: $tool is required to build OpenSSL"
        exit 1
    done
done

echo

echo '>>> Downloading OpenSSL source'
cd $SOURCES
wget -c https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz
tar xf openssl-$OPENSSL_VER.tar.gz

cd openssl-$OPENSSL_VER

echo '>>> Configuring OpenSSL'
# Configure with musl-compatible settings
./Configure \
    --prefix=/usr \
    --openssldir=/etc/ssl \
    --libdir=lib \
    no-shared \
    no-zlib \
    no-async \
    no-ssl3 \
    no-weak-ssl-ciphers \
    -DOPENSSL_NO_SSL3 \
    -DOPENSSL_NO_WEAK_SSL_CIPHERS \
    -DOPENSSL_NO_SSL3_METHOD \
    linux-$(uname -m) \
    -static \
    -fPIC \
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
make DESTDIR=$SYSROOT install_sw install_ssldirs

# Create version file to prevent recompilation
touch $REPO_ROOT/.openssl

echo '>>> OpenSSL installed successfully'
