#!/bin/sh -e
[ -f "$REPO_ROOT/.ncurses" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading ncurses source'
cd $SOURCES
wget -c https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VER.tar.gz
tar xf ncurses-$NCURSES_VER.tar.gz

cd ncurses-$NCURSES_VER

echo '>>> Downloading and applying official patches'
# Download official development patches
wget -c https://invisible-island.net/archives/ncurses/6.5/dev-patches.zip
unzip -o dev-patches.zip

# Apply all patches in order
for patch_file in *.patch.gz; do
    if [ -f "$patch_file" ]; then
        echo "Applying $patch_file"
        for n in ../ncurses-$NCURSES_VER-*.gz ; do zcat $n | patch -p1 ; done
    fi
done

echo '>>> Configuring ncurses'
# Configure with cross-compilation and musl-compatible settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CXXFLAGS="$CXXFLAGS -fPIC" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --with-shared \
    --with-cxx-shared \
    --without-debug \
    --without-normal \
    --enable-pc-files \
    --enable-widec \
    --with-pkg-config-libdir=/usr/lib/pkgconfig \
    --disable-stripping \
    --enable-overwrite \
    --with-termlib \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building ncurses'
make -j$(nproc)

echo '>>> Installing ncurses to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create symlinks for compatibility
cd $SYSROOT/usr/lib
$SUDO_CMD ln -sf libncursesw.so libncurses.so
$SUDO_CMD ln -sf libncursesw.a libncurses.a
$SUDO_CMD ln -sf libformw.so libform.so
$SUDO_CMD ln -sf libformw.a libform.a
$SUDO_CMD ln -sf libmenuw.so libmenu.so
$SUDO_CMD ln -sf libmenuw.a libmenu.a
$SUDO_CMD ln -sf libpanelw.so libpanel.so
$SUDO_CMD ln -sf libpanelw.a libpanel.a

# Create version file to prevent recompilation
touch $REPO_ROOT/.ncurses

echo '>>> ncurses installed successfully'
