#!/bin/sh -e
[ -f "$REPO_ROOT/.m4" ] && exit 0
SUDO_CMD="sudo"

# Use a specific version of om4 that's known to work

echo '>>> Downloading om4 source'
cd $SOURCES
rm -rf om4-$OM4_VER om4-$OM4_VERS.tar.gz
wget -c https://github.com/iglunix/om4/archive/refs/tags/v$OM4_VER.tar.gz -O om4-$OM4_VER.tar.gz
tar xf om4-$OM4_VER.tar.gz

cd om4-$OM4_VER

echo '>>> Building om4'
# First generate the parser files
yacc -d parser.y && mv y.tab.c parser.c && mv y.tab.h parser.h
./configure
# Then build with the generated parser files
CC="$CC" \
CFLAGS="$CFLAGS -I. -DHAVE_CONFIG_H" \
make -j$(nproc) all
mv om4 m4
echo '>>> Installing om4 to sysroot'
$SUDO_CMD make PROG=m4 DESTDIR=$SYSROOT PREFIX=/usr install

# Create m4 symlink for compatibility
$SUDO_CMD ln -sf om4 $SYSROOT/usr/bin/m4

# Create version file to prevent recompilation
touch $REPO_ROOT/.m4

echo '>>> om4 installed successfully'
