#!/bin/sh
[ -f "$REPO_ROOT/.gettext-tiny" ] && exit 0

# Set up environment
SUDO_CMD="sudo"
SYSROOT="$REPO_ROOT/sysroot"
GETTEXT_TINY_VER="0.3.2"
GETTEXT_TINY_TAR="gettext-tiny-${GETTEXT_TINY_VER}.tar.gz"
GETTEXT_TINY_URL="https://github.com/sabotage-linux/gettext-tiny/archive/refs/tags/v${GETTEXT_TINY_VER}.tar.gz"

# Create build directory
echo '>>> Setting up build directory'
cd $SOURCES
rm -rf "gettext-tiny-${GETTEXT_TINY_VER}" "${GETTEXT_TINY_TAR}"

# Download and extract gettext-tiny
echo '>>> Downloading gettext-tiny source'
wget -c "${GETTEXT_TINY_URL}" -O "${GETTEXT_TINY_TAR}"
tar xf "${GETTEXT_TINY_TAR}"

# Build and install gettext-tiny
echo '>>> Building and installing gettext-tiny'
cd "gettext-tiny-${GETTEXT_TINY_VER}"

# Use musl-clang for compilation
export CC="/usr/bin/musl-clang"
export CFLAGS="--sysroot=${SYSROOT} --target=${TARGET} -I${SYSROOT}/usr/include -L${SYSROOT}/usr/lib -fPIC -O2"
export LDFLAGS="--sysroot=${SYSROOT} -L${SYSROOT}/usr/lib"

# Build with NOOP libintl (simplest implementation)
make LIBINTL=NOOP

# Install to sysroot
echo '>>> Installing gettext-tiny to sysroot'
$SUDO_CMD make LIBINTL=NOOP DESTDIR="${SYSROOT}" prefix=/usr install

# Create a symlink for msgfmt to msgfmt-tt (to avoid conflicts with system gettext)
$SUDO_CMD ln -sf msgfmt "${SYSROOT}/usr/bin/msgfmt-tt"

# Create version file to prevent recompilation
touch "$REPO_ROOT/.gettext-tiny"

echo '>>> gettext-tiny installation complete'
