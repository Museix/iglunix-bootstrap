#!/bin/sh -e
[ -f "$REPO_ROOT/.zlib-ng" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading zlib-ng source'
cd $SOURCES
wget -c https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$ZLIB_NG_VER.tar.gz
tar xf $ZLIB_NG_VER.tar.gz

cd zlib-ng-$ZLIB_NG_VER

echo '>>> Configuring zlib-ng'
# Configure with CMake for better cross-compilation support
mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_SYSROOT=$SYSROOT \
    -DCMAKE_C_FLAGS="$CFLAGS -fPIC" \
    -DZLIB_COMPAT=ON \
    -DZLIB_ENABLE_TESTS=OFF \
    -DBUILD_SHARED_LIBS=ON

echo '>>> Building zlib-ng'
make -j$(nproc)

echo '>>> Installing zlib-ng to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.zlib-ng

echo '>>> zlib-ng installed successfully'
