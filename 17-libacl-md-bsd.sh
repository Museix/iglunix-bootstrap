#!/bin/sh -e
[ -f "$REPO_ROOT/.libacl-md-bsd" ] && exit 0

echo ">>> building libattr, libacl, libmd, and libbsd"

# Clean up any previous build directories
rm -rf "$BUILD/libattr" "$BUILD/libmd" "$BUILD/libbsd" "$BUILD/libacl"

# Create build directories
mkdir -p "$BUILD/libattr"
mkdir -p "$BUILD/libacl"
mkdir -p "$BUILD/libmd"
mkdir -p "$BUILD/libbsd"

# Build libattr (dependency for libacl)
cd "$SOURCES/attr-2.5.2"
./configure \
    --prefix=/usr \
    --host=$TARGET \
    --disable-shared \
    --enable-static \
    --with-build-sysroot="$SYSROOT" \
    --with-sysroot="$SYSROOT" \
    CC="$CC" \
    CFLAGS="$CFLAGS -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -D_GNU_SOURCE -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=700" \
    LDFLAGS="$LDFLAGS"
make -j$(nproc)
make DESTDIR="$SYSROOT" install

# Create and install libattr pkg-config file
mkdir -p "$SYSROOT/usr/lib/pkgconfig"
cat > "$SYSROOT/usr/lib/pkgconfig/libattr.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: libattr
Description: Filesystem extended attribute shared library
Version: 2.5.2
Libs: -L${libdir} -lattr
Cflags: -I${includedir}
EOF

# Build libmd (dependency for libbsd)
cd "$SOURCES/libmd-1.1.0"
./configure \
    --prefix=/usr \
    --host=$TARGET \
    --disable-shared \
    --enable-static \
    --with-build-sysroot="$SYSROOT" \
    --with-sysroot="$SYSROOT" \
    CC="$CC" \
    CFLAGS="$CFLAGS -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -D_GNU_SOURCE -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=700" \
    LDFLAGS="$LDFLAGS"
make -j$(nproc)
make DESTDIR="$SYSROOT" install

# Build libbsd
cd "$SOURCES/libbsd-0.11.7"
./configure \
    --prefix=/usr \
    --host=$TARGET \
    --disable-shared \
    --enable-static \
    --with-build-sysroot="$SYSROOT" \
    --with-sysroot="$SYSROOT" \
    --disable-werror \
    --disable-tests \
    CC="$CC" \
    CFLAGS="$CFLAGS -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -I$SYSROOT/usr/include" \
    LDFLAGS="$LDFLAGS -L$SYSROOT/usr/lib"
make -j$(nproc)
make DESTDIR="$SYSROOT" install

# Build libacl (depends on libattr)
cd "$SOURCES/acl-2.3.2"
./configure \
    --prefix=/usr \
    --host=$TARGET \
    --target=$TARGET \
    --build=x86_64-unknown-linux-gnu \
    --enable-shared \
    --enable-static \
    --with-build-sysroot="$SYSROOT" \
    --with-sysroot="$SYSROOT" \
    --disable-nls \
    CC="$CC" \
    CFLAGS="$CFLAGS -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -std=gnu99 -I$SYSROOT/usr/include" \
    LDFLAGS="$LDFLAGS -L$SYSROOT/usr/lib -lattr"
make -j$(nproc)
make DESTDIR="$SYSROOT" install

# Create and install libacl pkg-config file
mkdir -p "$SYSROOT/usr/lib/pkgconfig"
cat > "$SYSROOT/usr/lib/pkgconfig/libacl.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: acl
Description: Access control list shared library
Version: 2.3.2
Libs: -L${libdir} -lacl
Cflags: -I${includedir}
Requires.private: libattr
EOF

# Create a file to mark these as built
touch "$REPO_ROOT/.libacl-md-bsd"

echo "<<< libattr, libacl, libmd, and libbsd built successfully"
