#!/bin/sh -e
[ -f "$REPO_ROOT/.libxo-xml2-tinygettext" ] && exit 0

echo "=== Building libxo, libxml2, and tinygettext ==="

# Create build directories
echo "[1/3] Creating build directories..."
mkdir -p "$BUILD/libxo"
mkdir -p "$BUILD/libxml2"
mkdir -p "$BUILD/tinygettext"
cp -rL "$SOURCES/bheaded" "$BUILD/bheaded"
cd "$BUILD/bheaded"
make -j$(nproc)
make DESTDIR="$SYSROOT" PREFIX=/usr install

# Build libxml2 first (dependency for others)
echo "[2/3] Configuring libxml2..."
cd "$SOURCES/libxml2"
./autogen.sh \
    --prefix=/usr \
    --host=$TARGET \
    --disable-shared \
    --enable-static \
    --with-sysroot="$SYSROOT" \
    --without-python \
    --without-lzma \
    --without-zlib \
    --without-iconv \
    --without-icu \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS"
make -j$(nproc)
make DESTDIR="$SYSROOT" PREFIX=/usr install

# Create and install libxml2 pkg-config file
mkdir -p "$SYSROOT/usr/lib/pkgconfig"
cat > "$SYSROOT/usr/lib/pkgconfig/libxml-2.0.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
modules=1

Name: libXML
Version: 2.11.0
Description: libXML library version2.
Requires:
Libs: -L${libdir} -lxml2
Libs.private:  -lz  -llzma  -lm  -lz  
Cflags: -I${includedir}/libxml2
EOF

# Build libxo
echo "[3/4] Configuring libxo..."
cd "$SOURCES/libxo"
# Run autogen.sh if it exists, otherwise run autoreconf
if [ -f "autogen.sh" ]; then
    ./autogen.sh
else
    autoreconf -fiv
fi

# Create build directory and configure
mkdir -p "$BUILD/libxo"
cd "$BUILD/libxo"
"$SOURCES/libxo/configure" \
    --prefix=/usr \
    --host=$TARGET \
    --disable-shared \
    --enable-static \
    --with-sysroot="$SYSROOT" \
    --disable-libxo-options \
    --disable-xml \
    CC="$CC" \
    CFLAGS="$CFLAGS -I$SYSROOT/usr/include" \
    LDFLAGS="$LDFLAGS -L$SYSROOT/usr/lib"
echo "[3/4] Building and installing libxo..."
make -j$(nproc)
make DESTDIR="$SYSROOT" PREFIX=/usr install

# Create and install libxo pkg-config file
mkdir -p "$SYSROOT/usr/lib/pkgconfig"
cat > "$SYSROOT/usr/lib/pkgconfig/libxo.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: libxo
Description: Library for generating text, XML, JSON, and HTML output
Version: 1.6.0
Libs: -L${libdir} -lxo
Cflags: -I${includedir}
EOF

# Build tinygettext
echo "[4/5] Configuring tinygettext..."
cd "$SOURCES/tinygettext"
git submodule update --init --recursive
mkdir -p "$BUILD/tinygettext"
cd "$BUILD/tinygettext"
cmake "$SOURCES/tinygettext" \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_FIND_ROOT_PATH="$SYSROOT" \
    -DBUILD_SHARED_LIBS=OFF \
    -DTINYGETTEXT_BUILD_SAMPLES=OFF \
    -DTINYGETTEXT_BUILD_TESTS=OFF
echo "[4/5] Building and installing tinygettext..."
make -j$(nproc)
make DESTDIR="$SYSROOT" PREFIX=/usr install

# Create and install tinygettext pkg-config file
mkdir -p "$SYSROOT/usr/lib/pkgconfig"
cat > "$SYSROOT/usr/lib/pkgconfig/tinygettext.pc" << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: tinygettext
Description: A small C++ library for reading GNU gettext po files
Version: 1.0.0
Libs: -L${libdir} -ltinygettext
Cflags: -I${includedir}
EOF

# Create a file to mark these as built
#touch "$REPO_ROOT/.libxo-xml2-tinygettext"

echo "[5/5] === libxo, libxml2, and tinygettext built successfully ==="
echo "[✓] All components built and installed successfully!"

touch "$REPO_ROOT/.libxo-xml2-tinygettext"
