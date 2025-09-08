#!/bin/sh -e
[ -f "$REPO_ROOT/.byacc" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading byacc source'
cd $SOURCES
wget -c https://invisible-island.net/archives/byacc/byacc-$BYACC_VER.tgz
tar xf byacc-$BYACC_VER.tgz

cd byacc-$BYACC_VER

echo '>>> Configuring byacc'
# Configure with cross-compilation settings
CC="$CC" \
CFLAGS="$CFLAGS" \
./configure \
    --prefix=/usr \
    --mandir=/usr/share/man \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building byacc'
make -j$(nproc)

echo '>>> Installing byacc to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.byacc

echo '>>> byacc installed successfully'
