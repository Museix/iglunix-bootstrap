#!/bin/sh -e
[ -f "$REPO_ROOT/.samurai" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading samurai source'
cd $SOURCES
wget -c https://github.com/michaelforney/samurai/releases/download/$SAMURAI_VER/samurai-$SAMURAI_VER.tar.gz
tar xf samurai-$SAMURAI_VER.tar.gz

cd samurai-$SAMURAI_VER

echo '>>> Building samurai'
# samurai uses a simple Makefile, no configure step needed
CC="$CC" \
CFLAGS="$CFLAGS" \
make -j$(nproc)

echo '>>> Installing samurai to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT PREFIX=/usr install

# Create samu symlink (ninja-compatible name)
$SUDO_CMD ln -sf samurai $SYSROOT/usr/bin/samu

# Create version file to prevent recompilation
touch $REPO_ROOT/.samurai

echo '>>> samurai installed successfully'
