#!/bin/sh -e
[ -f "$REPO_ROOT/.libiconv" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading libiconv source'
cd $SOURCES
wget -c https://mirrors.dotsrc.org/gnu/libiconv/libiconv-$LIBICONV_VER.tar.gz
tar xf libiconv-$LIBICONV_VER.tar.gz

cd libiconv-$LIBICONV_VER

echo '>>> Configuring libiconv'
# Configure with cross-compilation and musl-compatible settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-shared \
    --enable-static \
    --disable-nls \
    --build=$(./build-aux/config.guess) \
    --host=$TARGET

echo '>>> Building libiconv'
make -j$(nproc)

echo '>>> Installing libiconv to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.libiconv

echo '>>> libiconv installed successfully'
