#!/bin/sh -e
[ -f "$REPO_ROOT/.uutils" ] && exit 0

echo ">>> building uutils-coreutils"

cd "$SOURCES"/coreutils-$UUTILS_VER

# Configure and build

RUSTFLAGS="$RUSTFLAGS" CARGOFLAGS="--target=x86_64-unknown-linux-musl" \
make SKIP_UTILS="pinky uptime users who stdbuf" \
    CARGO_BIN_NAME=uutils-coreutils \
    BUILDDIR=/home/lucy/src/iglunix-bootstrap/src/coreutils-0.2.2/target/x86_64-unknown-linux-musl/release \
    RELEASE=1 \
    STATIC=1 \
    CARGO_PROFILE_RELEASE_LTO=true \
    CARGOFLAGS="--target=x86_64-unknown-linux-musl" \
    SELINUX_DISABLE=true \
    PROFILE=release \
    PREFIX=/usr \
    SYSROOT=$SYSROOT \
    HOST=$TARGET \
    MUSL_ROOT=$SYSROOT \
    CC="$CC" \
    CXX="$CXX" \
    CFLAGS="$CFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    strip=true \
    SKIP_UTILS="pinky uptime users who stdbuf chcon runcon" build
if [ -f "$REPO_ROOT/.uutilspatched" ]; then
    echo "uutils-coreutils patches applied already, skipping"
    else
    for patch in "$REPO_ROOT/patches/uutils/"*.patch; do
        echo "Applying patch: $(basename "$patch")"
        cpatch < "$patch"
    done
    touch $REPO_ROOT/.uutilspatched
    rm GNUmakefile.orig
fi
make \
    CARGO_BIN_NAME=uutils-coreutils \
    BUILDDIR=/home/lucy/src/iglunix-bootstrap/src/coreutils-0.2.2/target/x86_64-unknown-linux-musl/release \
    RELEASE=1 \
    STATIC=1 \
    CARGO_PROFILE_RELEASE_LTO=true \
    CARGOFLAGS="--target=x86_64-unknown-linux-musl" \
    SELINUX_DISABLE=true \
    PREFIX=/usr \
    SYSROOT=$SYSROOT \
    HOST=$TARGET \
    MUSL_ROOT=$SYSROOT \
    CC="$CC" \
    CXX="$CXX" \
    CFLAGS="$CFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS" \
    strip=true \
    SKIP_UTILS="pinky uptime users who stdbuf chcon runcon" PREFIX=/usr DESTDIR=$SYSROOT install

touch $REPO_ROOT/.uutils
