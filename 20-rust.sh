#!/bin/sh -e

# Check if Rust is already built
if [ -f "$REPO_ROOT/.rust" ]; then
    echo "Rust already built. Remove $REPO_ROOT/.rust to rebuild."
    exit 0
fi

# Ensure required tools are available
for cmd in curl tar make; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Build LLVM and tablegen if needed
env -u CFLAGS -u CXXFLAGS -u LDFLAGS ./11-tblgen.sh
./12-llvm.sh

# Ensure SSL certificates are available
mkdir -p "$SYSROOT/etc/ssl/certs"
if [ ! -e "$SYSROOT/etc/ssl/cert.pem" ]; then
    echo "Downloading CA certificates..."
    if ! curl -L --retry 3 https://curl.se/ca/cacert.pem -o "$SYSROOT/etc/ssl/cert.pem"; then
        echo "Warning: Failed to download CA certificates, using insecure connection"
        curl -k -L https://curl.se/ca/cacert.pem -o "$SYSROOT/etc/ssl/cert.pem"
    fi
fi

echo "\n>>> Building Rust $RUST_VER for $ARCH"
echo "========================================"

# Ensure rustup is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Set up build directory
cd "$SOURCES/rustc-$RUST_VER-src"


# Set up environment for cross-compilation
export PATH="/usr/lib/llvm20/bin:$PATH"
export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"

# Set up Cargo config
rm -rf bootstrap.toml
# Set target-specific environment variables
export TARGET="x86_64-chimera-linux-musl"
target_upper=$(echo "$TARGET" | tr '[:lower:]-' '[:upper:]_')
export "CARGO_TARGET_${target_upper}_LINKER"="clang"
export "CARGO_TARGET_${target_upper}_RUSTFLAGS"="-C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
export CBUILD_TARGET_SYSROOT=$SYSROOT
# Configure Rust build
echo "Configuring Rust build..."
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --release-channel=stable \
    --llvm-config=/usr/bin/llvm-config \
    --llvm-root=/usr \
    --llvm-libunwind=system \
    --enable-llvm-link-shared \
    --disable-docs \
    --enable-extended \
    --tools=rustc,rustfmt,clippy,src,rustdoc,rust-demangler \
    --enable-vendor \
    --enable-option-checking \
    --target=x86_64-chimera-linux-musl \
    --host=x86_64-chimera-linux-musl \
    --set=rust.lto=thin \
    --set=rust.codegen-units=1 \
    --set=rust.remap-debuginfo=true \
    --set=llvm.download-ci-llvm=if-available || {
        echo "Error: Failed to configure Rust"
        exit 1
    }
# Apply patches from the rust directory
if [ -f "$REPO_ROOT/.rustpatched" ]; then
    echo "Rust patches applied already, skipping"
else
if [ -d "$REPO_ROOT/patches/rust" ]; then
    for patch in "$REPO_ROOT/patches/rust/"*.patch; do
        if [ -f "$patch" ]; then
            echo "Applying patch: $(basename "$patch")"
            cpatch -p1 < "$patch" || {
                echo "Error: Failed to apply patch $(basename "$patch")"
                exit 1
            }
        fi
    done
fi
fi
sed -i 's/\("files":{\)[^}]*/\1/' vendor/*/.cargo-checksum.json
sed -i 's/\("deny-warnings":{\)[^}]*/\1/' bootstrap.toml
touch $REPO_ROOT/.rustpatched
# Build Rust
echo "Building Rust (this will take a while)..."
make -j"$(nproc)" || {
    echo "Error: Failed to build Rust"
    exit 1
}

# Build Rust components with Cargo
echo "Building Rust components with Cargo..."
./x.py build --stage 2 || {
    echo "Error: Failed to build Rust components with Cargo"
    exit 1
}

# Install Rust
echo "Installing Rust..."
make install DESTDIR="$SYSROOT" || {
    echo "Error: Failed to install Rust"
    exit 1
}

# Verify installation
if [ -f "$SYSROOT/usr/bin/rustc" ]; then
    echo "\n=== Rust installation successful ==="
    "$SYSROOT/usr/bin/rustc" --version
    touch "$REPO_ROOT/.rust"
else
    echo "Error: Rust installation failed - rustc not found"
    exit 1
fi
