#!/bin/sh -e
set -x

# Check if fetching has already been done
[ -f "$REPO_ROOT/.fetched" ] && exit 0

echo
echo '>>> fetching'
echo

# Function to download and extract a tarball if not already present
fetch_and_extract_tarball() {
    URL=$1
    DEST_FILE=$2
    EXTRACT_DIR=$3
    RENAMED_DIR=$4

    if [ ! -f "$DEST_FILE" ]; then
        curl -L "$URL" -o "$DEST_FILE"
    else
        echo "Skipping download: $DEST_FILE already exists."
    fi

    if [ ! -d "$EXTRACT_DIR" ]; then
        tar -xf "$DEST_FILE" -C "$SOURCES"
        if [ -n "$RENAMED_DIR" ] && [ -d "$SOURCES/$(basename $RENAMED_DIR)" ]; then
            mv "$SOURCES/$(basename $RENAMED_DIR)" "$EXTRACT_DIR"
        fi
    else
        echo "Skipping extraction: $EXTRACT_DIR already exists."
    fi
}

# Function to clone a git repository if not already present
fetch_git_repo() {
    REPO_URL=$1
    DEST_DIR=$2

    if [ ! -d "$DEST_DIR" ]; then
        git clone "$REPO_URL" "$DEST_DIR"
    else
        echo "Skipping clone: $DEST_DIR already exists."
    fi
}

# Fetch and extract Linux headers
fetch_and_extract_tarball "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" "$SOURCES/linux-$KERN_VER.tar.xz" "$SOURCES/linux-$KERN_VER"

# Fetch and extract Musl
fetch_and_extract_tarball "https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz" "$SOURCES/musl-$MUSL_VER.tar.gz" "$SOURCES/musl-$MUSL_VER"

# Fetch and extract LLVM
fetch_and_extract_tarball "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" "$SOURCES/llvm-$LLVM_VER.tar.xz" "$SOURCES/llvm-$LLVM_VER" "llvm-project-$LLVM_VER.src"
sed -i 's|set(LLVM_USE_HOST_TOOLS ON)|set(LLVM_USE_HOST_TOOLS OFF)|g' "$SOURCES/llvm-$LLVM_VER/llvm/CMakeLists.txt"

# Fetch and extract mksh
fetch_and_extract_tarball "https://mbsd.evolvis.org/MirOS/dist/mir/mksh/mksh-$MKSH_VER.tgz" "$SOURCES/mksh-$MKSH_VER.tgz" "$SOURCES/mksh-$MKSH_VER" "mksh"

# Clone posixutils-rs
fetch_git_repo "https://github.com/rustcoreutils/posixutils-rs.git" "$SOURCES/posixutils-rs"

# Fetch and extract busybox
fetch_and_extract_tarball "https://busybox.net/downloads/busybox-$BUSYBOX_VER.tar.bz2" "$SOURCES/busybox-$BUSYBOX_VER.tar.bz2" "$SOURCES/busybox-$BUSYBOX_VER"

# Fetch and extract Rust source
fetch_and_extract_tarball "https://static.rust-lang.org/dist/rustc-1.89.0-src.tar.gz" "$SOURCES/rustc-1.89.0-src.tar.gz" "$SOURCES/rustc-1.89.0-src"
cp "$REPO_ROOT/rust-museix.patch" "$SOURCES/rustc-1.89.0-src/rust-museix.patch"

touch "$REPO_ROOT/.fetched"