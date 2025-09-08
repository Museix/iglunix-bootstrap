#!/bin/sh -e
[ -f "$REPO_ROOT/.libmd" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading libmd source'
cd $SOURCES
wget -c https://archive.hadrons.org/software/libmd/libmd-$LIBMD_VER.tar.xz
tar xf libmd-$LIBMD_VER.tar.xz

cd libmd-$LIBMD_VER

echo '>>> Configuring libmd'
# Configure with cross-compilation settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-shared \
    --enable-static \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building libmd'
make -j$(nproc)

echo '>>> Installing libmd to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.libmd

echo '>>> libmd installed successfully'
