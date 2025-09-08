#!/bin/sh -e
[ -f "$REPO_ROOT/.fetched" ] && exit 0

echo
echo '>>> Checking and fetching sources'
echo

# Function to download a file if it doesn't exist
download_if_not_exists() {
    local url=$1
    local dest=$2
    
    if [ ! -f "$dest" ]; then
        echo "Downloading $url..."
        curl -L "$url" -o "$dest"
    else
        echo "Skipping download of $(basename "$dest") - already exists"
    fi
}

# Function to extract an archive if the target directory doesn't exist
extract_if_not_exists() {
    local src=$1
    local dest_dir=$2
    local extract_cmd=$3
    
    if [ ! -d "$dest_dir" ]; then
        echo "Extracting $(basename "$src")..."
        $extract_cmd "$src" -C "$SOURCES"
    else
        echo "Skipping extraction of $(basename "$src") - target directory exists"
    fi
}

# Download source files if they don't exist
download_if_not_exists "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" "$SOURCES/linux-$KERN_VER.tar.xz"
download_if_not_exists "https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz" "$SOURCES/musl-$MUSL_VER.tar.gz"
download_if_not_exists "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" "$SOURCES/llvm-$LLVM_VER.tar.xz"
download_if_not_exists "https://mbsd.evolvis.org/MirOS/dist/mir/mksh/mksh-$MKSH_VER.tgz" "$SOURCES/mksh-$MKSH_VER.tgz"
download_if_not_exists "http://landley.net/toybox/downloads/toybox-$TOYBOX_VER.tar.gz" "$SOURCES/toybox-$TOYBOX_VER.tar.gz"
download_if_not_exists "https://busybox.net/downloads/busybox-$BUSYBOX_VER.tar.bz2" "$SOURCES/busybox-$BUSYBOX_VER.tar.bz2"
download_if_not_exists "https://www.crufty.net/ftp/pub/sjg/bmake-$BMAKE_VER.tar.gz" "$SOURCES/bmake-$BMAKE_VER.tar.gz"

echo
echo '>>> Extracting sources'
echo

# Extract source files if the target directories don't exist
extract_if_not_exists "$SOURCES/linux-$KERN_VER.tar.xz" "$SOURCES/linux-$KERN_VER" "tar -xf"
extract_if_not_exists "$SOURCES/musl-$MUSL_VER.tar.gz" "$SOURCES/musl-$MUSL_VER" "tar -xf"
extract_if_not_exists "$SOURCES/llvm-$LLVM_VER.tar.xz" "$SOURCES/llvm-project-$LLVM_VER.src" "tar -xf"

# Special handling for LLVM directory structure
if [ -d "$SOURCES/llvm-project-$LLVM_VER.src" ] && [ ! -d "$SOURCES/llvm-$LLVM_VER" ]; then
    mv "$SOURCES/llvm-project-$LLVM_VER.src" "$SOURCES/llvm-$LLVM_VER"
    sed -i 's|set(LLVM_USE_HOST_TOOLS ON)|set(LLVM_USE_HOST_TOOLS OFF)|g' "$SOURCES/llvm-$LLVM_VER/llvm/CMakeLists.txt"
elif [ -d "$SOURCES/llvm-$LLVM_VER" ]; then
    echo "Skipping LLVM directory setup - already exists"
fi

extract_if_not_exists "$SOURCES/toybox-$TOYBOX_VER.tar.gz" "$SOURCES/toybox-$TOYBOX_VER" "tar -xf"
extract_if_not_exists "$SOURCES/busybox-$BUSYBOX_VER.tar.bz2" "$SOURCES/busybox-$BUSYBOX_VER" "tar -xf"

# Special handling for mksh
extract_if_not_exists "$SOURCES/mksh-$MKSH_VER.tgz" "$SOURCES/mksh-$MKSH_VER" "tar -xf"
if [ -d "$SOURCES/mksh" ] && [ ! -d "$SOURCES/mksh-$MKSH_VER" ]; then
    mv "$SOURCES/mksh" "$SOURCES/mksh-$MKSH_VER"
elif [ -d "$SOURCES/mksh-$MKSH_VER" ]; then
    echo "Skipping mksh directory setup - already exists"
fi

# Extract bmake if not already extracted
extract_if_not_exists "$SOURCES/bmake-$BMAKE_VER.tar.gz" "$SOURCES/bmake-$BMAKE_VER" "tar -xf"

touch $REPO_ROOT/.fetched
