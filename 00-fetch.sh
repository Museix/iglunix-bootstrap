#!/bin/sh -e
[ -f "$REPO_ROOT/.fetched" ] && exit 0

echo
echo '>>> fetching'
echo

# Download files only if they don't exist
[ ! -f "$SOURCES/linux-$KERN_VER.tar.xz" ] && curl "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" -o $SOURCES/linux-$KERN_VER.tar.xz
[ ! -f "$SOURCES/musl-$MUSL_VER.tar.gz" ] && curl "https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz" -o $SOURCES/musl-$MUSL_VER.tar.gz
[ ! -f "$SOURCES/llvm-$LLVM_VER.tar.xz" ] && curl -L "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" -o $SOURCES/llvm-$LLVM_VER.tar.xz
[ ! -f "$SOURCES/mksh-$MKSH_VER.tgz" ] && curl -L "https://mbsd.evolvis.org/MirOS/dist/mir/mksh/mksh-$MKSH_VER.tgz" -o $SOURCES/mksh-$MKSH_VER.tgz
[ ! -f "$SOURCES/toybox-$TOYBOX_VER.tar.gz" ] && curl -L "http://landley.net/toybox/downloads/toybox-$TOYBOX_VER.tar.gz" -o $SOURCES/toybox-$TOYBOX_VER.tar.gz
[ ! -f "$SOURCES/busybox-$BUSYBOX_VER.tar.bz2" ] && curl -L "https://busybox.net/downloads/busybox-$BUSYBOX_VER.tar.bz2" -o $SOURCES/busybox-$BUSYBOX_VER.tar.bz2

# Remove extracted directories before extracting to ensure clean extraction
rm -rf $SOURCES/linux-$KERN_VER
rm -rf $SOURCES/musl-$MUSL_VER
rm -rf $SOURCES/llvm-$LLVM_VER
rm -rf $SOURCES/llvm-project-$LLVM_VER.src
rm -rf $SOURCES/mksh-$MKSH_VER
rm -rf $SOURCES/mksh
rm -rf $SOURCES/toybox-$TOYBOX_VER
rm -rf $SOURCES/busybox-$BUSYBOX_VER

tar -xf $SOURCES/linux-$KERN_VER.tar.xz -C $SOURCES
tar -xf $SOURCES/musl-$MUSL_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/llvm-$LLVM_VER.tar.xz -C $SOURCES
mv $SOURCES/llvm-project-$LLVM_VER.src $SOURCES/llvm-$LLVM_VER
sed -i 's|set(LLVM_USE_HOST_TOOLS ON)|set(LLVM_USE_HOST_TOOLS OFF)|g' $SOURCES/llvm-$LLVM_VER/llvm/CMakeLists.txt
tar -xf $SOURCES/toybox-$TOYBOX_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/busybox-$BUSYBOX_VER.tar.bz2 -C $SOURCES

tar -xf $SOURCES/mksh-$MKSH_VER.tgz -C $SOURCES
mv $SOURCES/mksh $SOURCES/mksh-$MKSH_VER

# Apply patches
cd $SOURCES/musl-$MUSL_VER
for patch in "$REPO_ROOT/patches/musl/musl-"*.patch; do
    echo "Applying patch: $(basename "$patch")"
    patch -p1 < "$patch"
done
cd $SOURCES/busybox-$BUSYBOX_VER
for patch in "$REPO_ROOT/patches/busybox/busybox-"*.patch; do
    echo "Applying patch: $(basename "$patch")"
    patch -p1 < "$patch"
done
cd $SOURCES/llvm-$LLVM_VER
for patch in "$REPO_ROOT/patches/llvm/"*.patch; do
    echo "Applying patch: $(basename "$patch")"
    ~/.local/chimera-bin/bin/patch -p1 < "$patch"
done

touch $REPO_ROOT/.fetched
