#!/bin/sh -e
[ -f "$REPO_ROOT/.rust" ] && exit 0
env -u CFLAGS -u CXXFLAGS -u LDFLAGS ./11-tblgen.sh
./12-llvm.sh


extra_args=
if [ ! -e $SYSROOT/etc/ssl/cert.pem ]
then
	printf 'WARNING: using insecure protocol for downloading certificates\n'
	extra_args=-k
fi
curl $extra_args -L https://curl.haxx.se/ca/cacert.pem -o $SYSROOT/etc/ssl/cert.pem

echo ">>> building rust from source using rustup-managed toolchain"

# Ensure rustup is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

cd "$BUILD"
rm -rf rustc-$RUST_VER-src
tar -xf "$SOURCES/rustc-$RUST_VER-src.tar.gz"
cd rustc-$RUST_VER-src

# Apply any patches if they exist in the patches directory

# Set LD_LIBRARY_PATH to prioritize sysroot libraries
export LD_LIBRARY_PATH="$SYSROOT/usr/lib:$SYSROOT/lib:$LD_LIBRARY_PATH"

# Set musl-root environment variable
export CARGO_TARGET_$(echo $ARCH-unknown-linux-musl | tr '[:lower:]-' '[:upper:]_')_MUSL_ROOT="$SYSROOT"

# Configure and build
    CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" ./configure --prefix=/usr --sysconfdir=/etc \
    --build=$ARCH-unknown-linux-gnu \
    --host=$ARCH-unknown-linux-musl \
    --target=$ARCH-unknown-linux-musl \
    --musl-root-$ARCH=$SYSROOT \
    --release-channel=stable \
	--set="target.$TARGET.llvm-config=$SYSROOT/usr/bin/llvm-config" \
			--llvm-root="/usr" \
			--llvm-libunwind="system" \
			--enable-llvm-link-shared \
			--disable-docs \
			--enable-extended \
			--tools="cargo,rustfmt,rls,src" \
			--enable-vendor \
			--disable-locked-deps \
			--enable-option-checking 
make -j$(nproc)
make install

touch $REPO_ROOT/.rust
