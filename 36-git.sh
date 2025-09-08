#!/bin/sh
[ -f "$REPO_ROOT/.gitp" ] && exit 0

# Set up environment
SUDO_CMD="sudo"
SYSROOT="$REPO_ROOT/sysroot"
GIT_VER="2.45.1"
GIT_TAR="git-${GIT_VER}.tar.gz"
GIT_URL="https://github.com/git/git/archive/refs/tags/v${GIT_VER}.tar.gz"
BUILD_DIR="$SOURCES/git-${GIT_VER}-build"

# Create build directory
echo '>>> Setting up build directory'
cd $SOURCES
rm -rf "git-${GIT_VER}" "${BUILD_DIR}" "${GIT_TAR}"

# Install build dependencies if not already installed
# Download and extract Git
echo '>>> Downloading Git source'
wget -c "${GIT_URL}" -O "${GIT_TAR}"
tar xf "${GIT_TAR}"

cd "${SOURCES}/git-${GIT_VER}"

# Set up environment for cross-compilation
export CC="/usr/bin/musl-clang"
export CFLAGS="--sysroot=${SYSROOT} --target=${TARGET} -I${SYSROOT}/usr/include -L${SYSROOT}/usr/lib -rtlib=compiler-rt -unwindlib=libunwind -Wno-unused-command-line-argument -fuse-ld=lld"
export LDFLAGS="--sysroot=${SYSROOT} -L${SYSROOT}/usr/lib -rtlib=compiler-rt -unwindlib=libunwind -fuse-ld=lld"

# Fix inet_ntop conflict
echo '#undef inet_ntop' > ${SOURCES}/git-${GIT_VER}/compat/inet_ntop.h

# Generate configure script
echo '>>> Generating configure script'
make configure
# Configure Git build
echo '>>> Configuring Git build'
./configure \
    --prefix=/usr \
    --host=${TARGET} \
    --with-curl=/usr \
    --with-openssl=/usr \
    --with-libpcre2=/usr \
    --with-expat=/usr \
    --with-zlib=/usr \
    --with-perl=/usr/bin/perl \
    --without-tcltk \
    --without-python \
    --without-iconv \
    --without-pager \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-libpcre2 \
    --with-expat \
    NO_GETTEXT=1 \
    NO_INSTALL_HARDLINKS=1 \
    NO_SYS_POLL_H=1 \
    NO_UNIX_SOCKETS=1 \
    NO_IPV6=1 \
    NO_MMAP=1 \
    NO_SETENV=1 \
    NO_SETITIMER=1 \
    NO_UNSETENV=1 \
    NO_SYMLINK_HEAD=1 \
    NO_SYSLOG=1 \
    NO_INET_NTOP=1 \
    NO_INET_PTON=1 \
    NO_NSEC=1 \
    NO_OPENSSL=1 \
    NO_POSIX_GOODIES=1 \
    NO_REGEX=1 \
    NO_SYMLINK_HEAD=1 \
    NO_SYS_SELECT_H=1 \
    NO_SYS_WAIT_H=1 \
    NO_TRUSTABLE_FILEMODE=1 \
    NO_STRTOUMAX=1

# Build Git
echo '>>> Building Git'
make -j$(nproc)

# Install to sysroot
echo '>>> Installing Git to sysroot'
$SUDO_CMD make DESTDIR="${SYSROOT}" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.gitp"

echo '>>> Git installation complete'
