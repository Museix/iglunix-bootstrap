#!/bin/sh -e
[ -f "$REPO_ROOT/.flex" ] && exit 0
SUDO_CMD="sudo"

# First, install system flex if not available
if ! command -v flex >/dev/null 2>&1; then
    echo '>>> Installing system flex...'
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y flex
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm flex
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y flex
    else
        echo '!!! Could not find a package manager to install flex. Please install it manually.'
        exit 1
    fi
fi

# Use the system flex to build a static musl-linked flex
FLEX_TAR="flex-${FLEX_VER}.tar.gz"
FLEX_URL="https://github.com/westes/flex/releases/download/v${FLEX_VER}/${FLEX_TAR}"

echo '>>> Downloading flex source'
cd $SOURCES
rm -rf flex-${FLEX_VER} ${FLEX_TAR}
wget -c ${FLEX_URL}
tar xf ${FLEX_TAR}

cd flex-${FLEX_VER}

echo '>>> Configuring flex'
./configure \
    --prefix=/usr \
    --build=$(./build-aux/config.guess) \
    --host=$TARGET \
    --disable-nls \
    --disable-dependency-tracking \
    --enable-bootstrap \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS"

echo '>>> Building flex'
make -j$(nproc)

echo '>>> Installing flex to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create version file to prevent recompilation
touch $REPO_ROOT/.flex

echo '>>> flex installed successfully'
