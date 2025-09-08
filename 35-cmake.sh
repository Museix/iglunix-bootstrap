#!/bin/sh -e
[ -f "$REPO_ROOT/.cmake" ] && exit 0

# Set up environment
SUDO_CMD="sudo"
SYSROOT="$REPO_ROOT/sysroot"
TARGET="x86_64-iglunix-linux-musl"
CMAKE_TAR="cmake-${CMAKE_VER}.tar.gz"
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/${CMAKE_TAR}"
BUILD_DIR="$SOURCES/cmake-${CMAKE_VER}-build"

# Create build directory
echo '>>> Setting up build directory'
cd $SOURCES
rm -rf "cmake-${CMAKE_VER}" "${BUILD_DIR}" "${CMAKE_TAR}"

# Check if we have a working CMake
if ! command -v cmake >/dev/null 2>&1; then
    echo '>>> No working CMake found, building a minimal version first'
    wget -c "${CMAKE_URL}"
    tar xf "${CMAKE_TAR}"
    
    # Build minimal CMake
    mkdir -p "${BUILD_DIR}-minimal"
    cd "${BUILD_DIR}-minimal"
    "${SOURCES}/cmake-${CMAKE_VER}/bootstrap" --prefix=/usr --parallel=$(nproc) --no-qt-gui --no-system-libs --no-system-jsoncpp --no-system-librhash --no-system-liblzma --no-system-zstd
    make -j$(nproc)
    
    # Use the minimal CMake to build the full version
    export PATH="${PWD}/bin:${PATH}"
    cd ..
fi

# Download and extract CMake
echo '>>> Downloading CMake source'
wget -c "${CMAKE_URL}"
tar xf "${CMAKE_TAR}"

# Create and enter build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure full CMake build
echo '>>> Configuring full CMake build'
cmake -G Ninja "${SOURCES}/cmake-${CMAKE_VER}" \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_FLAGS="--sysroot=${SYSROOT} --target=x86_64-linux-musl -rtlib=compiler-rt -unwindlib=libunwind -stdlib=libc++ -Wno-unused-command-line-argument -fuse-ld=lld" \
    -DCMAKE_CXX_FLAGS="--sysroot=${SYSROOT} --target=x86_64-linux-musl -nostdinc++ -isystem ${SYSROOT}/usr/include/c++/v1 -rtlib=compiler-rt -stdlib=libc++ -unwindlib=libunwind -Wno-unused-command-line-argument -fuse-ld=lld" .

# Build full CMake
echo '>>> Building full CMake'
samu -j$(nproc)

# Install to sysroot
echo '>>> Installing CMake to sysroot'
$SUDO_CMD DESTDIR="${SYSROOT}" samu install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.cmake"

echo '>>> CMake installation complete'
