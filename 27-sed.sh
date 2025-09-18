#!/bin/sh -e
[ -f "$REPO_ROOT/.sed" ] && exit 0

echo ">>> building uutils-sed"

cd "$SOURCES"/sed

# Build only the sed utility

cargo build --release --target=x86_64-unknown-linux-musl $CARGOFLAGS --features="uudoc" --bin sedapp 
# Install the binary
install -Dm755 "target/x86_64-unknown-linux-musl/release/sedapp" "$SYSROOT/usr/bin/sed"

touch "$REPO_ROOT/.sed"
