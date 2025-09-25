#!/bin/sh -e
[ -f "$REPO_ROOT/.rust" ] && exit 0

cd $SOURCES/rustc-1.89.0-src

/usr/local/bin/cpatch -p1 < rust-museix.patch

./configure --prefix=$SYSROOT/usr \
    --release-channel=stable

make -j$(nproc) install-std target=$ARCH-museix-linux-musl

mkdir -p ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-museix-linux-musl
cp -r $SYSROOT/usr/lib/rustlib/x86_64-museix-linux-musl/lib ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-museix-linux-musl/

touch $REPO_ROOT/.rust