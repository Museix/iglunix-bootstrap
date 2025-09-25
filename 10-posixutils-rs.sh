#!/bin/sh -e
[ -f "$REPO_ROOT/.posixutils-rs" ] && exit 0

rustup toolchain link museix $SYSROOT/usr
export RUSTUP_TOOLCHAIN=museix

cd $SOURCES/posixutils-rs

export RUST_TARGET=$ARCH-museix-linux-musl
if [ "$ARCH" = "riscv64" ]; then
    export RUST_TARGET=riscv64gc-museix-linux-musl
fi

export PROJECT_NAME=posixutils-rs

rustup target add $RUST_TARGET

mkdir -p .cargo
cat > .cargo/config.toml <<EOF
[target.$RUST_TARGET]
linker = "$CC"
ar = "$AR"
EOF

cargo build --release --target $RUST_TARGET

for util in $(ls target/$RUST_TARGET/release); do
    cp target/$RUST_TARGET/release/$util $SYSROOT/bin
done

touch $REPO_ROOT/.posixutils-rs
