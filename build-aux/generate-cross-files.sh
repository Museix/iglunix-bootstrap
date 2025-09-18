#!/bin/sh
set -e

REPO_ROOT=$(realpath $(dirname $0)/..)
CROSS_DIR="$REPO_ROOT/build-aux/cross"

# Ensure cross directory exists
mkdir -p "$CROSS_DIR"

create_cross_file() {
    local arch=$1
    local target=$2
    
    case "$arch" in
        x86_64)  local cpu="x86_64" ;;
        aarch64) local cpu="aarch64" ;;
        riscv64) local cpu="riscv64" ;;
        *) echo "Unsupported architecture: $arch"; exit 1 ;;
    esac

    # Create a minimal cross file
    cat > "$CROSS_DIR/${target}-linux-musl.ini" << EOF
[binaries]
c = 'clang'
cpp = 'clang++'
ar = 'llvm-ar'
strip = 'llvm-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = '${cpu}'
cpu = '${cpu}'
endian = 'little'

[properties]
root = '\$SYSROOT'
pkg_config_libdir = ['\$SYSROOT/usr/lib/pkgconfig', '\$SYSROOT/usr/share/pkgconfig']

[built-in options]
c_args = [
    '--target=${target}-linux-musl',
    '--sysroot=\$SYSROOT',
    '-fpie',
    '-fpic',
    '-rtlib=compiler-rt',
    '-unwindlib=libunwind',
    '-fuse-ld=lld',
    '-D_GNU_SOURCE',
    '-D_DEFAULT_SOURCE',
    '-D_XOPEN_SOURCE=600',
    '-D_FILE_OFFSET_BITS=64',
    '-D_CHIMERAUTILS_BUILD',
    '-Dlint'
]
c_link_args = [
    '--target=${target}-linux-musl',
    '--sysroot=\$SYSROOT',
    '-static',
    '-fuse-ld=lld',
    '-rtlib=compiler-rt',
    '-unwindlib=libunwind',
    '-Wl,-z,now',
    '-Wl,-z,relro',
    '-lm'
]
cpp_args = [
    '--target=${target}-linux-musl',
    '--sysroot=\$SYSROOT',
    '-fpie',
    '-fpic',
    '-nostdinc++',
    '-isystem', '\$SYSROOT/usr/include/c++/v1',
    '-isystem', '\$SYSROOT/usr/include',
    '-rtlib=compiler-rt',
    '-stdlib=libc++',
    '-unwindlib=libunwind',
    '-fuse-ld=lld',
    '-D_GNU_SOURCE',
    '-D_DEFAULT_SOURCE',
    '-D_XOPEN_SOURCE=600',
    '-D_FILE_OFFSET_BITS=64',
    '-D_CHIMERAUTILS_BUILD',
    '-fno-rtti',
    '-fno-exceptions'
]
cpp_link_args = [
    '--target=${target}-linux-musl',
    '--sysroot=\$SYSROOT',
    '-static',
    '-fuse-ld=lld',
    '-rtlib=compiler-rt',
    '-stdlib=libc++',
    '-unwindlib=libunwind',
    '-Wl,-z,now',
    '-Wl,-z,relro',
    '-lm'
]

[cmake]
CMAKE_SYSROOT = '\$SYSROOT'
EOF
}

# Create cross files for all architectures
for arch in x86_64 aarch64 riscv64; do
    echo "Generating cross file for $arch..."
    create_cross_file "$arch" "$arch"
done

echo "Successfully generated cross-compilation files in $CROSS_DIR/"
ls -l "$CROSS_DIR/"
