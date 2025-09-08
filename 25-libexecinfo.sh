#!/bin/sh -e
[ -f "$REPO_ROOT/.libexecinfo" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading libexecinfo source'
cd $SOURCES
wget -c https://github.com/fam007e/libexecinfo/archive/refs/tags/v$LIBEXECINFO_VER.tar.gz
tar xf v$LIBEXECINFO_VER.tar.gz

cd libexecinfo-$LIBEXECINFO_VER

echo '>>> Building libexecinfo'
# libexecinfo uses a simple Makefile
CC="$CC" \
CFLAGS="$CFLAGS -fPIC" \
make -j$(nproc)

echo '>>> Installing libexecinfo to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT PREFIX=/usr install

# Create pkg-config file for libexecinfo
$SUDO_CMD mkdir -p $SYSROOT/usr/lib/pkgconfig
$SUDO_CMD tee $SYSROOT/usr/lib/pkgconfig/libexecinfo.pc > /dev/null << EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libexecinfo
Description: A portable backtrace library
Version: $LIBEXECINFO_VER
Libs: -L\${libdir} -lexecinfo
Cflags: -I\${includedir}
EOF

# Create version file to prevent recompilation
touch $REPO_ROOT/.libexecinfo

echo '>>> libexecinfo installed successfully'
