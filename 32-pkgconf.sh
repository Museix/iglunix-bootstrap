#!/bin/sh -e
[ -f "$REPO_ROOT/.pkgconf" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading pkgconf source'
cd $SOURCES
wget -c https://distfiles.ariadne.space/pkgconf/pkgconf-$PKGCONF_VER.tar.xz
tar xf pkgconf-$PKGCONF_VER.tar.xz

cd pkgconf-$PKGCONF_VER

echo '>>> Configuring pkgconf'
# Configure with cross-compilation settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib" \
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-pkg-config-dir=/usr/lib/pkgconfig:/usr/share/pkgconfig \
    --with-system-libdir=/usr/lib \
    --with-system-includedir=/usr/include \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building pkgconf'
make -j$(nproc)

echo '>>> Installing pkgconf to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create pkg-config symlink for compatibility
$SUDO_CMD ln -sf pkgconf $SYSROOT/usr/bin/pkg-config

# Create version file to prevent recompilation
touch $REPO_ROOT/.pkgconf

echo '>>> pkgconf installed successfully'
