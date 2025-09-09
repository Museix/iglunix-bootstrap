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
export CFLAGS="--sysroot=${SYSROOT} --target=${TARGET} -I${SYSROOT}/usr/include -L${SYSROOT}/usr/lib -fPIC -O2"
export LDFLAGS="--sysroot=${SYSROOT} -L${SYSROOT}/usr/lib -fuse-ld=lld"

# Fix inet_ntop conflict
echo '#undef inet_ntop' > ${SOURCES}/git-${GIT_VER}/compat/inet_ntop.h

# Create necessary symlinks for gettext-tiny
$SUDO_CMD ln -sf /usr/bin/msgfmt-tt ${SYSROOT}/usr/bin/msgfmt
$SUDO_CMD ln -sf /usr/bin/xgettext ${SYSROOT}/usr/bin/xgettext-tt || true

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
    --without-send-email \
    --without-svn \
    --without-cvs \
    --without-git-gui \
    --without-gitk \
    --without-git-upload-archive \
    --without-git-upload-pack \
    --without-git-receive-pack \
    --without-git-shell \
    --without-git-cvsserver \
    --without-git-upload-archive-http \
    --without-git-upload-pack-http \
    --without-git-receive-pack-http \
    --without-git-shell-http \
    --without-git-cvsserver-http \
    --without-git-upload-archive-https \
    --without-git-upload-pack-https \
    --without-git-receive-pack-https \
    --without-git-shell-https \
    --without-git-cvsserver-https \
    --without-git-upload-archive-ftp \
    --without-git-upload-pack-ftp \
    --without-git-receive-pack-ftp \
    --without-git-shell-ftp \
    --without-git-cvsserver-ftp \
    --without-git-upload-archive-ftps \
    --without-git-upload-pack-ftps \
    --without-git-receive-pack-ftps \
    --without-git-shell-ftps \
    --without-git-cvsserver-ftps \
    --without-git-upload-archive-git \
    --without-git-upload-pack-git \
    --without-git-receive-pack-git \
    --without-git-shell-git \
    --without-git-cvsserver-git \
    --without-git-upload-archive-ssh \
    --without-git-upload-pack-ssh \
    --without-git-receive-pack-ssh \
    --without-git-shell-ssh \
    --without-git-cvsserver-ssh \
    --without-git-upload-archive-rsync \
    --without-git-upload-pack-rsync \
    --without-git-receive-pack-rsync \
    --without-git-shell-rsync \
    --without-git-cvsserver-rsync \
    --without-git-upload-archive-file \
    --without-git-upload-pack-file \
    --without-git-receive-pack-file \
    --without-git-shell-file \
    --without-git-cvsserver-file \
    --without-git-upload-archive-rsync \
    --without-git-upload-pack-rsync \
    --without-git-receive-pack-rsync \
    --without-git-shell-rsync \
    --without-git-cvsserver-rsync \
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
    NO_SYS_SELECT_H=1 \
    NO_SYS_WAIT_H=1 \
    NO_TRUSTABLE_FILEMODE=1 \
    NO_STRTOUMAX=1

# Install build dependencies
if ! command -v gcc >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1; then
    echo '>>> Installing build dependencies'
    $SUDO_CMD pacman -S --noconfirm --needed base-devel gcc make libcurl-compat openssl pcre2 zlib zlib-ng-compat
fi

# Build Git
echo '>>> Building Git'
make -j$(nproc)

# Install to sysroot
echo '>>> Installing Git to sysroot'
$SUDO_CMD make DESTDIR="${SYSROOT}" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.gitp"

echo '>>> Git installation complete'
