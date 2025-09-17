#!/bin/sh -e
echo
echo '>>> [1/4] fetching required sources'
echo

# Download files only if they don't exist
echo ">> fetching Linux $KERN_VER"
[ ! -f "$SOURCES/linux-$KERN_VER.tar.xz" ] && curl -L --retry 3 "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" -o $SOURCES/linux-$KERN_VER.tar.xz
echo ">> fetching musl $MUSL_VER"
[ ! -f "$SOURCES/musl-$MUSL_VER.tar.gz" ] && curl -L --retry 3 "https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz" -o $SOURCES/musl-$MUSL_VER.tar.gz
echo ">> fetching LLVM $LLVM_VER"
[ ! -f "$SOURCES/llvm-$LLVM_VER.tar.xz" ] && curl -L --retry 3 "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" -o $SOURCES/llvm-$LLVM_VER.tar.xz
echo ">> fetching dash $DASH_VER"
[ ! -f "$SOURCES/dash-$DASH_VER.tar.gz" ] && curl -L --retry 3 "https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/dash-$DASH_VER.tar.gz" -o "$SOURCES/dash-$DASH_VER.tar.gz"
echo ">> fetching GNU Make $GMAKE_VER"
[ ! -f "$SOURCES/make-$GMAKE_VER.tar.gz" ] && curl -L --retry 3 "https://ftp.gnu.org/gnu/make/make-$GMAKE_VER.tar.gz" -o $SOURCES/make-$GMAKE_VER.tar.gz
echo ">> fetching zlib-ng $ZLIB_NG_VER"
[ ! -f "$SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz" ] && curl -L --retry 3 "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$ZLIB_NG_VER.tar.gz" -o $SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz
echo ">> fetching OpenSSL $OPENSSL_VER"
[ ! -f "$SOURCES/openssl-$OPENSSL_VER.tar.gz" ] && curl -L --retry 3 "https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz" -o $SOURCES/openssl-$OPENSSL_VER.tar.gz
echo ">> fetching cryptlib $CRYPTLIB_VER"
[ ! -f "$SOURCES/cryptlib-$CRYPTLIB_VER.zip" ] && curl -L --retry 3 "https://github.com/cryptlib/cryptlib/archive/refs/tags/v$CRYPTLIB_VER.zip" -o $SOURCES/cryptlib-$CRYPTLIB_VER.zip
echo ">> fetching ncurses $NCURSES_VER"
[ ! -f "$SOURCES/ncurses-$NCURSES_VER.tar.gz" ] && curl -L --retry 3 "https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VER.tar.gz" -o $SOURCES/ncurses-$NCURSES_VER.tar.gz
echo ">> fetching oniguruma $ONIGURUMA_VER"
[ ! -f "$SOURCES/onig-$ONIGURUMA_VER.tar.gz" ] && curl -L --retry 3 "https://github.com/kkos/oniguruma/releases/download/v$ONIGURUMA_VER/onig-$ONIGURUMA_VER.tar.gz" -o "$SOURCES/onig-$ONIGURUMA_VER.tar.gz"
echo ">> fetching Rust $RUST_VER"
[ ! -f "$SOURCES/rustc-$RUST_VER-src.tar.gz" ] && curl -L --retry 3 "https://static.rust-lang.org/dist/rustc-$RUST_VER-src.tar.gz" -o "$SOURCES/rustc-$RUST_VER-src.tar.gz"
echo ">> fetching uutils-coreutils $UUTILS_VER"
[ ! -f "$SOURCES/uutils-coreutils-$UUTILS_VER.tar.gz" ] && curl -L --retry 3 "https://github.com/uutils/coreutils/archive/refs/tags/$UUTILS_VER.tar.gz" -o "$SOURCES/uutils-coreutils-$UUTILS_VER.tar.gz"
echo ">> fetching util-linux $UTIL_LINUX_VER"
[ ! -f "$SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz" ] && curl -L --retry 3 "https://www.kernel.org/pub/linux/utils/util-linux/v${UTIL_LINUX_VER%.*}/util-linux-$UTIL_LINUX_VER.tar.gz" -o "$SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz"
echo ">> fetching pkgconf $PKGCONF_VER"
[ ! -f "$SOURCES/pkgconf-$PKGCONF_VER.tar.xz" ] && curl -L --retry 3 "https://distfiles.dereferenced.org/pkgconf/pkgconf-$PKGCONF_VER.tar.xz" -o "$SOURCES/pkgconf-$PKGCONF_VER.tar.xz"
echo ">> fetching sqlite $SQLITE_VER"
[ ! -f "$SOURCES/sqlite-src-$SQLITE_VER_CODE.zip" ] && curl -L --retry 3 "https://sqlite.org/2025/sqlite-src-$SQLITE_VER_CODE.zip" -o "$SOURCES/sqlite-src-$SQLITE_VER_CODE.zip"
echo
echo '>>> [2/4] cleaning up old sources'
echo
if [ -f "$REPO_ROOT/.clean" ]; then
# Remove extracted directories before extracting to ensure clean extraction
rm -rf $SOURCES/linux-$KERN_VER
rm -rf $SOURCES/musl-$MUSL_VER
rm -rf $SOURCES/llvm-$LLVM_VER
rm -rf $SOURCES/llvm-project-$LLVM_VER.src
rm -rf $SOURCES/dash-$DASH_VER
rm -rf $SOURCES/make-$GMAKE_VER
rm -rf $SOURCES/zlib-ng-$ZLIB_NG_VER
rm -rf $SOURCES/openssl-$OPENSSL_VER
rm -rf $SOURCES/cryptlib-$CRYPTLIB_VER
rm -rf $SOURCES/ncurses-$NCURSES_VER
rm -rf $SOURCES/libedit
rm -rf $SOURCES/onig-$ONIGURUMA_VER
rm -rf $SOURCES/rustc-$RUST_VER-src
rm -rf $SOURCES/uutils-coreutils-$UUTILS_VER
rm -rf $SOURCES/util-linux-$UTIL_LINUX_VER
rm -rf $SOURCES/pkgconf-$PKGCONF_VER
rm -rf $SOURCES/libpsl-$LIBPSL_VER
rm -rf $SOURCES/libunistring-$LIBUNISTRING_VER
rm -rf $SOURCES/libatomic
rm -rf $SOURCES/curl
rm -rf $SOURCES/libexecinfo
rm -rf $SOURCES/sqlite-src-$SQLITE_VER_CODE
fi

echo
echo '>>> [3/4] extracting new sources'
echo

echo ">> extracting Linux"
if [ ! -d "$SOURCES/linux-$KERN_VER" ]; then
    tar -xf $SOURCES/linux-$KERN_VER.tar.xz -C $SOURCES
fi
echo ">> extracting musl"
if [ ! -d "$SOURCES/musl-$MUSL_VER" ]; then
    tar -xf $SOURCES/musl-$MUSL_VER.tar.gz -C $SOURCES
fi
echo ">> extracting LLVM"
if [ ! -d "$SOURCES/llvm-$LLVM_VER" ]; then
    tar -xf $SOURCES/llvm-$LLVM_VER.tar.xz -C $SOURCES
mv $SOURCES/llvm-project-$LLVM_VER.src $SOURCES/llvm-$LLVM_VER
sed -i 's|set(LLVM_USE_HOST_TOOLS ON)|set(LLVM_USE_HOST_TOOLS OFF)|g' $SOURCES/llvm-$LLVM_VER/llvm/CMakeLists.txt
fi
echo ">> extracting dash"
if [ ! -d "$SOURCES/dash-$DASH_VER" ]; then
    tar -xf $SOURCES/dash-$DASH_VER.tar.gz -C $SOURCES
fi
echo ">> extracting GNU Make"
if [ ! -d "$SOURCES/make-$GMAKE_VER" ]; then
    tar -xf $SOURCES/make-$GMAKE_VER.tar.gz -C $SOURCES
fi
echo ">> extracting zlib-ng"
if [ ! -d "$SOURCES/zlib-ng-$ZLIB_NG_VER" ]; then
    tar -xf $SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz -C $SOURCES
fi
echo ">> extracting OpenSSL"
if [ ! -d "$SOURCES/openssl-$OPENSSL_VER" ]; then
    tar -xf $SOURCES/openssl-$OPENSSL_VER.tar.gz -C $SOURCES
fi
echo ">> extracting cryptlib"
if [ ! -d "$SOURCES/cryptlib-$CRYPTLIB_VER" ]; then
    unzip -aqq $SOURCES/cryptlib-$CRYPTLIB_VER.zip -d $SOURCES/cryptlib-$CRYPTLIB_VER
fi
echo ">> extracting ncurses"
if [ ! -d "$SOURCES/ncurses-$NCURSES_VER" ]; then
    tar -xf $SOURCES/ncurses-$NCURSES_VER.tar.gz -C $SOURCES
fi
echo ">> extracting oniguruma"
if [ ! -d "$SOURCES/onig-$ONIGURUMA_VER" ]; then
    tar -xf $SOURCES/onig-$ONIGURUMA_VER.tar.gz -C $SOURCES
fi
echo ">> extracting Rust"
if [ ! -d "$SOURCES/rustc-$RUST_VER-src" ]; then
    tar -xf $SOURCES/rustc-$RUST_VER-src.tar.gz -C $SOURCES
fi
echo ">> extracting uutils-coreutils"
if [ ! -d "$SOURCES/uutils-coreutils-$UUTILS_VER" ]; then
    tar -xf $SOURCES/uutils-coreutils-$UUTILS_VER.tar.gz -C $SOURCES
fi
echo ">> extracting util-linux"
if [ ! -d "$SOURCES/util-linux-$UTIL_LINUX_VER" ]; then
    tar -xf $SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz -C $SOURCES
fi
echo ">> extracting pkgconf"
if [ ! -d "$SOURCES/pkgconf-$PKGCONF_VER" ]; then
    tar -xf $SOURCES/pkgconf-$PKGCONF_VER.tar.xz -C $SOURCES
fi
echo ">> extracting sqlite"
if [ ! -d "$SOURCES/sqlite-src-$SQLITE_VER_CODE" ]; then
    unzip -q $SOURCES/sqlite-src-$SQLITE_VER_CODE.zip -d $SOURCES
fi
echo ">> fetching libedit (git)"
if [ ! -d "$SOURCES/libedit" ]; then
    git clone https://github.com/chimera-linux/libedit-chimera.git "$SOURCES/libedit"
fi
echo ">> fetching libatomic (git)"
if [ ! -d "$SOURCES/libatomic" ]; then
    git clone https://github.com/chimera-linux/libatomic-chimera.git "$SOURCES/libatomic"
fi
echo ">> fetching curl (git)"
if [ ! -d "$SOURCES/curl" ]; then
    git clone https://github.com/curl/curl.git "$SOURCES/curl"
fi
echo ">> fetching libexecinfo (git)"
if [ ! -d "$SOURCES/libexecinfo" ]; then
    git clone https://github.com/fam007e/libexecinfo.git "$SOURCES/libexecinfo"
fi
echo ">> fetching libexecinfo (git)"
if [ ! -d "$SOURCES/libexecinfo" ]; then
    git clone https://github.com/fam007e/libexecinfo.git "$SOURCES/libexecinfo"
fi

echo
echo '>>> [4/4] patching sources'
echo

# Apply patches
cd $SOURCES/musl-$MUSL_VER
if [ -f "$REPO_ROOT/.muslpatched" ]; then
    echo "musl patches applied already, skipping"
else
    for patch in "$REPO_ROOT/patches/musl/musl-"*.patch; do
        echo "Applying patch: $(basename "$patch")"
        patch -p1 -N --silent < "$patch"
    done
    touch $REPO_ROOT/.muslpatched
fi
cd $SOURCES/coreutils-$UUTILS_VER
