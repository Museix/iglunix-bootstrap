#!/bin/sh -e
[ -f "$REPO_ROOT/.openpam" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading OpenPAM source'
cd $SOURCES
wget -c https://www.openpam.org/downloads/openpam-$OPENPAM_VER.tar.gz
tar xf openpam-$OPENPAM_VER.tar.gz

cd openpam-$OPENPAM_VER

# Apply musl compatibility fix
echo '>>> Applying musl compatibility fix for fpurge'
# For musl, we'll use fflush(stdin) which is the standard way to clear input buffer
sed -i 's/fpurge(stdin);/fflush(stdin);/' lib/libpam/openpam_ttyconv.c

echo '>>> Configuring OpenPAM'
# Configure with cross-compilation and musl-compatible settings
CC="$CC" \
CXX="$CXX" \
CFLAGS="$CFLAGS -fPIC" \
CPPFLAGS="-I$SYSROOT/usr/include" \
LDFLAGS="-L$SYSROOT/usr/lib" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --enable-shared \
    --enable-static \
    --with-modules-dir=/usr/lib/security \
    --build=$(./config.guess) \
    --host=$TARGET

echo '>>> Building OpenPAM'
make -j$(nproc)

echo '>>> Installing OpenPAM to sysroot'
$SUDO_CMD make DESTDIR=$SYSROOT install

# Create basic PAM configuration directory
$SUDO_CMD mkdir -p $SYSROOT/etc/pam.d
$SUDO_CMD mkdir -p $SYSROOT/usr/lib/security

# Create basic system-auth PAM configuration
$SUDO_CMD tee $SYSROOT/etc/pam.d/system-auth > /dev/null << 'EOF'
#%PAM-1.0
# System-wide authentication configuration for Iglunix

auth        required    pam_unix.so
account     required    pam_unix.so
password    required    pam_unix.so
session     required    pam_unix.so
EOF

# Create version file to prevent recompilation
touch $REPO_ROOT/.openpam

echo '>>> OpenPAM installed successfully'
