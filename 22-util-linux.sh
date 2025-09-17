#!/bin/sh -e
[ -f "$REPO_ROOT/.util-linux" ] && exit 0
./25-sqlite.sh
echo ">>> building util-linux"

cd "$BUILD"
rm -rf util-linux-$UTIL_LINUX_VER
tar -xf "$SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz"
cd util-linux-$UTIL_LINUX_VER

# Configure and build
./configure --prefix=/usr \
            --host=$TARGET \
            --build=x86_64-unknown-linux-gnu \
            --target=$TARGET \
            --enable-static \
            --with-sysroot=$SYSROOT \
            --without-python \
            --without-systemd \
            --without-udev

make -j$(nproc)
sudo make DESTDIR=$SYSROOT install

touch $REPO_ROOT/.util-linux
