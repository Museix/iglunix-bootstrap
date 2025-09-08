#!/bin/sh -e
[ -f "$REPO_ROOT/.musl-fts" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading musl-fts source'
cd $SOURCES
wget -c https://github.com/kilea-chan/musl-fts/archive/refs/tags/v$FTS_VER.tar.gz -O musl-fts-$FTS_VER.tar.gz
tar xf musl-fts-$FTS_VER.tar.gz

cd musl-fts-$FTS_VER

echo '>>> Configuring musl-fts with meson'
# Create build directory
mkdir -p build
cd build

# Configure with meson
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
meson setup \
    --prefix=/usr \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
    ..

echo '>>> Building musl-fts'
ninja

echo '>>> Installing musl-fts to sysroot'
$SUDO_CMD DESTDIR="$SYSROOT" ninja install

# Create version file to prevent recompilation
touch $REPO_ROOT/.musl-fts

echo '>>> musl-fts installed successfully'
