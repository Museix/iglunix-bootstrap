#!/bin/sh -e
[ -f "$REPO_ROOT/.fetched" ] && exit 0

echo
echo '>>> fetching'
echo

# Download files only if they don't exist
[ ! -f "$SOURCES/linux-$KERN_VER.tar.xz" ] && curl -L --retry 3 "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" -o $SOURCES/linux-$KERN_VER.tar.xz
[ ! -f "$SOURCES/musl-$MUSL_VER.tar.gz" ] && curl -L --retry 3 "https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz" -o $SOURCES/musl-$MUSL_VER.tar.gz
[ ! -f "$SOURCES/llvm-$LLVM_VER.tar.xz" ] && curl -L --retry 3 "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" -o $SOURCES/llvm-$LLVM_VER.tar.xz
[ ! -f "$SOURCES/mksh-$MKSH_VER.tgz" ] && curl -L --retry 3 "https://mbsd.evolvis.org/MirOS/dist/mir/mksh/mksh-$MKSH_VER.tgz" -o $SOURCES/mksh-$MKSH_VER.tgz
[ ! -f "$SOURCES/toybox-$TOYBOX_VER.tar.gz" ] && curl -L --retry 3 "http://landley.net/toybox/downloads/toybox-$TOYBOX_VER.tar.gz" -o $SOURCES/toybox-$TOYBOX_VER.tar.gz
[ ! -f "$SOURCES/busybox-$BUSYBOX_VER.tar.bz2" ] && curl -L --retry 3 "https://busybox.net/downloads/busybox-$BUSYBOX_VER.tar.bz2" -o $SOURCES/busybox-$BUSYBOX_VER.tar.bz2
[ ! -f "$SOURCES/make-$GMAKE_VER.tar.gz" ] && curl -L --retry 3 "https://ftp.gnu.org/gnu/make/make-$GMAKE_VER.tar.gz" -o $SOURCES/make-$GMAKE_VER.tar.gz
[ ! -f "$SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz" ] && curl -L --retry 3 "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$ZLIB_NG_VER.tar.gz" -o $SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz
[ ! -f "$SOURCES/openssl-$OPENSSL_VER.tar.gz" ] && curl -L --retry 3 "https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz" -o $SOURCES/openssl-$OPENSSL_VER.tar.gz
[ ! -f "$SOURCES/cryptlib-$CRYPTLIB_VER.tar.gz" ] && curl -L --retry 3 "https://github.com/cryptlib/cryptlib/archive/refs/tags/v$CRYPTLIB_VER.zip" -o $SOURCES/cryptlib-$CRYPTLIB_VER.zip
[ ! -f "$SOURCES/ncurses-$NCURSES_VER.tar.gz" ] && curl -L --retry 3 "https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VER.tar.gz" -o $SOURCES/ncurses-$NCURSES_VER.tar.gz

# Remove extracted directories before extracting to ensure clean extraction
rm -rf $SOURCES/linux-$KERN_VER
rm -rf $SOURCES/musl-$MUSL_VER
rm -rf $SOURCES/llvm-$LLVM_VER
rm -rf $SOURCES/llvm-project-$LLVM_VER.src
rm -rf $SOURCES/mksh-$MKSH_VER
rm -rf $SOURCES/mksh
rm -rf $SOURCES/toybox-$TOYBOX_VER
rm -rf $SOURCES/busybox-$BUSYBOX_VER
rm -rf $SOURCES/make-$GMAKE_VER
rm -rf $SOURCES/zlib-ng-$ZLIB_NG_VER
rm -rf $SOURCES/openssl-$OPENSSL_VER
rm -rf $SOURCES/cryptlib-$CRYPTLIB_VER
rm -rf $SOURCES/ncurses-$NCURSES_VER
rm -rf $SOURCES/libedit-$LIBEDIT_VER

tar -xf $SOURCES/linux-$KERN_VER.tar.xz -C $SOURCES
tar -xf $SOURCES/musl-$MUSL_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/llvm-$LLVM_VER.tar.xz -C $SOURCES
mv $SOURCES/llvm-project-$LLVM_VER.src $SOURCES/llvm-$LLVM_VER
sed -i 's|set(LLVM_USE_HOST_TOOLS ON)|set(LLVM_USE_HOST_TOOLS OFF)|g' $SOURCES/llvm-$LLVM_VER/llvm/CMakeLists.txt
tar -xf $SOURCES/toybox-$TOYBOX_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/busybox-$BUSYBOX_VER.tar.bz2 -C $SOURCES
tar -xf $SOURCES/make-$GMAKE_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz -C $SOURCES
tar -xf $SOURCES/openssl-$OPENSSL_VER.tar.gz -C $SOURCES
unzip -a $SOURCES/cryptlib-$CRYPTLIB_VER.zip -d $SOURCES/cryptlib-$CRYPTLIB_VER
tar -xf $SOURCES/ncurses-$NCURSES_VER.tar.gz -C $SOURCES

tar -xf $SOURCES/mksh-$MKSH_VER.tgz -C $SOURCES
mv $SOURCES/mksh $SOURCES/mksh-$MKSH_VER

tar -xf $SOURCES/libedit-$LIBEDIT_VER.tar.gz -C $SOURCES

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

# Apply any patches if they exist in the patches directory
if [ -d "$REPO_ROOT/patches/make" ]; then
    cd "$GMAKE_SRC"
    for patch in "$REPO_ROOT/patches/make/"*.patch; do
        if [ -f "$patch" ]; then
            log "Applying patch: $(basename "$patch")"
            patch -p1 < "$patch"
        fi
    done
fi

touch $REPO_ROOT/.fetched
