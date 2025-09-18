#!/bin/sh -e

# Function to download with retries and fallback
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=5
    local retry_delay=5
    local retry_count=0
    
    # Try curl first
    while [ $retry_count -lt $max_retries ]; do
        if command -v curl >/dev/null 2>&1; then
            echo "Attempting to download with curl... (attempt $((retry_count + 1)) of $max_retries)"
            if curl -L --connect-timeout 60 --max-time 300 --retry 2 --retry-delay 10 --retry-max-time 300 -f "$url" -o "$output"; then
                echo "Download completed successfully"
                return 0
            fi
        fi
        
        # If curl fails or not available, try wget
        if command -v wget >/dev/null 2>&1; then
            echo "curl failed, trying wget... (attempt $((retry_count + 1)) of $max_retries)"
            if wget --tries=2 --timeout=60 --waitretry=10 --read-timeout=300 -O "$output" "$url"; then
                echo "Download completed successfully with wget"
                return 0
            fi
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "Download failed, retrying in ${retry_delay} seconds..."
            sleep $retry_delay
            # Increase delay for next retry with a max of 5 minutes
            retry_delay=$((retry_delay * 2))
            [ $retry_delay -gt 300 ] && retry_delay=300
        fi
    done
    
    echo "Failed to download $url after $max_retries attempts"
    return 1
}

export -f download_with_retry
echo
echo '>>> [1/4] fetching required sources'
echo

# Download files only if they don't exist
echo ">> fetching Linux $KERN_VER"
[ ! -f "$SOURCES/linux-$KERN_VER.tar.xz" ] && download_with_retry "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERN_VER.tar.xz" "$SOURCES/linux-$KERN_VER.tar.xz"

echo ">> fetching musl $MUSL_VER"
[ ! -f "$SOURCES/musl-$MUSL_VER.tar.gz" ] && download_with_retry "http://git.etalabs.net/cgit/musl/snapshot/musl-$MUSL_VER.tar.gz" "$SOURCES/musl-$MUSL_VER.tar.gz"
echo ">> fetching LLVM $LLVM_VER"
[ ! -f "$SOURCES/llvm-$LLVM_VER.tar.xz" ] && download_with_retry "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-project-$LLVM_VER.src.tar.xz" "$SOURCES/llvm-$LLVM_VER.tar.xz"
echo ">> fetching dash $DASH_VER"
[ ! -f "$SOURCES/dash-$DASH_VER.tar.gz" ] && download_with_retry "https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/dash-$DASH_VER.tar.gz" "$SOURCES/dash-$DASH_VER.tar.gz"

echo ">> fetching GNU Make $GMAKE_VER"
[ ! -f "$SOURCES/make-$GMAKE_VER.tar.gz" ] && download_with_retry "https://ftp.gnu.org/gnu/make/make-$GMAKE_VER.tar.gz" "$SOURCES/make-$GMAKE_VER.tar.gz"

echo ">> fetching zlib-ng $ZLIB_NG_VER"
[ ! -f "$SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz" ] && download_with_retry "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$ZLIB_NG_VER.tar.gz" "$SOURCES/zlib-ng-$ZLIB_NG_VER.tar.gz"

echo ">> fetching OpenSSL $OPENSSL_VER"
[ ! -f "$SOURCES/openssl-$OPENSSL_VER.tar.gz" ] && download_with_retry "https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz" "$SOURCES/openssl-$OPENSSL_VER.tar.gz"

echo ">> fetching cryptlib $CRYPTLIB_VER"
[ ! -f "$SOURCES/cryptlib-$CRYPTLIB_VER.zip" ] && download_with_retry "https://github.com/cryptlib/cryptlib/archive/refs/tags/v$CRYPTLIB_VER.zip" "$SOURCES/cryptlib-$CRYPTLIB_VER.zip"
echo ">> fetching ncurses $NCURSES_VER"
[ ! -f "$SOURCES/ncurses-$NCURSES_VER.tar.gz" ] && download_with_retry "https://invisible-mirror.net/archives/ncurses/ncurses-$NCURSES_VER.tar.gz" -o $SOURCES/ncurses-$NCURSES_VER.tar.gz
echo ">> fetching oniguruma $ONIGURUMA_VER"
[ ! -f "$SOURCES/onig-$ONIGURUMA_VER.tar.gz" ] && download_with_retry "https://github.com/kkos/oniguruma/releases/download/v$ONIGURUMA_VER/onig-$ONIGURUMA_VER.tar.gz" -o "$SOURCES/onig-$ONIGURUMA_VER.tar.gz"
echo ">> fetching Rust $RUST_VER"
[ ! -f "$SOURCES/rustc-$RUST_VER-src.tar.gz" ] && download_with_retry "https://static.rust-lang.org/dist/rustc-$RUST_VER-src.tar.gz" -o "$SOURCES/rustc-$RUST_VER-src.tar.gz"
echo ">> fetching uutils-coreutils $UUTILS_VER"
[ ! -f "$SOURCES/uutils-coreutils-$UUTILS_VER.tar.gz" ] && download_with_retry "https://github.com/uutils/coreutils/archive/refs/tags/$UUTILS_VER.tar.gz" -o "$SOURCES/uutils-coreutils-$UUTILS_VER.tar.gz"
echo ">> fetching aee $AEE_VER"
[ ! -f "$SOURCES/aee-$AEE_VER.tar.gz" ] && download_with_retry "https://github.com/anoraktrend/aee/archive/refs/tags/$AEE_VER.tar.gz" -o "$SOURCES/aee-$AEE_VER.tar.gz"
echo ">> fetching util-linux $UTIL_LINUX_VER"
[ ! -f "$SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz" ] && download_with_retry "https://www.kernel.org/pub/linux/utils/util-linux/v${UTIL_LINUX_VER%.*}/util-linux-$UTIL_LINUX_VER.tar.gz" -o "$SOURCES/util-linux-$UTIL_LINUX_VER.tar.gz"
echo ">> fetching pkgconf $PKGCONF_VER"
[ ! -f "$SOURCES/pkgconf-$PKGCONF_VER.tar.xz" ] && download_with_retry "https://distfiles.dereferenced.org/pkgconf/pkgconf-$PKGCONF_VER.tar.xz" -o "$SOURCES/pkgconf-$PKGCONF_VER.tar.xz"
echo ">> fetching sqlite $SQLITE_VER"
[ ! -f "$SOURCES/sqlite-src-$SQLITE_VER_CODE.zip" ] && download_with_retry "https://sqlite.org/2025/sqlite-src-$SQLITE_VER_CODE.zip" -o "$SOURCES/sqlite-src-$SQLITE_VER_CODE.zip"
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
rm -rf $SOURCES/amp-$AMP_VER
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

# Fetch musl-standalone components
echo ">> fetching musl-standalone components"

# musl-fts
if [ ! -d "$SOURCES/musl-standalone/musl-fts" ]; then
    mkdir -p "$SOURCES/musl-standalone/musl-fts"
    git clone --depth=1 https://github.com/void-linux/musl-fts "$SOURCES/musl-standalone/musl-fts"
fi

# musl-obstack
if [ ! -d "$SOURCES/musl-standalone/musl-obstack" ]; then
    mkdir -p "$SOURCES/musl-standalone/musl-obstack"
    git clone --depth=1 https://github.com/void-linux/musl-obstack "$SOURCES/musl-standalone/musl-obstack"
fi

# musl-nscd (name service caching daemon)
if [ ! -d "$SOURCES/musl-standalone/musl-nscd" ]; then
    mkdir -p "$SOURCES/musl-standalone/musl-nscd"
    git clone --depth=1 https://github.com/pikhq/musl-nscd "$SOURCES/musl-standalone/musl-nscd"
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
echo ">> fetching uutils-sed (git)"
if [ ! -d "$SOURCES/sed" ]; then
    git clone https://github.com/uutils/sed.git "$SOURCES/sed"
fi
echo ">> fetching aee (git)"
if [ ! -d "$SOURCES/aee" ]; then
    git clone https://github.com/anoraktrend/aee.git "$SOURCES/aee"
fi
echo ">> fetching chimerautils (git)"
# Clone chimerautils if it doesn't exist
if [ ! -d "$SOURCES/chimerautils" ]; then
    git clone --depth=1 --recurse-submodules https://github.com/chimera-linux/chimerautils.git $SOURCES/chimerautils
fi

# Add libattr, libacl, libmd, and libbsd sources
echo '>> fetching libattr 2.5.2'
if [ ! -f "$SOURCES/attr-2.5.2.tar.xz" ]; then
    download_with_retry \
        "https://download.savannah.nongnu.org/releases/attr/attr-2.5.2.tar.xz" \
        "$SOURCES/attr-2.5.2.tar.xz"
fi

if [ ! -d "$SOURCES/attr-2.5.2" ]; then
    tar -xf "$SOURCES/attr-2.5.2.tar.xz" -C "$SOURCES"
fi

echo '>> fetching libacl 2.3.2'
if [ ! -f "$SOURCES/acl-2.3.2.tar.xz" ]; then
    download_with_retry \
        "https://download.savannah.nongnu.org/releases/acl/acl-2.3.2.tar.xz" \
        "$SOURCES/acl-2.3.2.tar.xz"
fi

if [ ! -d "$SOURCES/acl-2.3.2" ]; then
    tar -xf "$SOURCES/acl-2.3.2.tar.xz" -C "$SOURCES"
fi

echo '>> fetching libmd 1.1.0'
if [ ! -f "$SOURCES/libmd-1.1.0.tar.xz" ]; then
    download_with_retry \
        "https://libbsd.freedesktop.org/releases/libmd-1.1.0.tar.xz" \
        "$SOURCES/libmd-1.1.0.tar.xz"
fi

if [ ! -d "$SOURCES/libmd-1.1.0" ]; then
    tar -xf "$SOURCES/libmd-1.1.0.tar.xz" -C "$SOURCES"
fi

echo '>> fetching libbsd 0.11.7'
if [ ! -f "$SOURCES/libbsd-0.11.7.tar.xz" ]; then
    download_with_retry \
        "https://libbsd.freedesktop.org/releases/libbsd-0.11.7.tar.xz" \
        "$SOURCES/libbsd-0.11.7.tar.xz"
fi

if [ ! -d "$SOURCES/libbsd-0.11.7" ]; then
    tar -xf "$SOURCES/libbsd-0.11.7.tar.xz" -C "$SOURCES"
fi

# Add libxo, libxml2, and tinygettext sources
echo '>> fetching libxo (git)'
if [ ! -d "$SOURCES/libxo" ]; then
    git clone --depth=1 --recurse-submodules https://github.com/Juniper/libxo.git "$SOURCES/libxo"
    cd "$SOURCES/libxo"
    git fetch --tags
    git checkout 1.6.0
    git submodule update --init --recursive
fi

echo '>> fetching libxml2 (git)'
if [ ! -d "$SOURCES/libxml2" ]; then
    git clone --depth=1 --recurse-submodules https://gitlab.gnome.org/GNOME/libxml2.git "$SOURCES/libxml2"
    cd "$SOURCES/libxml2"
    git fetch --tags
    git checkout v2.12.7
    git submodule update --init --recursive
fi

echo '>> fetching tinygettext (git)'
if [ ! -d "$SOURCES/tinygettext" ]; then
    git clone --depth=1 --recurse-submodules https://github.com/tinygettext/tinygettext.git "$SOURCES/tinygettext"
    cd "$SOURCES/tinygettext"
    git submodule update --init --recursive
fi

echo '>> fetching bheaded (git)'
if [ ! -d "$SOURCES/bheaded" ]; then
    git clone --depth=1 --recurse-submodules https://github.com/anoraktrend/bheaded.git "$SOURCES/bheaded"
    cd "$SOURCES/bheaded"
    git submodule update --init --recursive
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

# Apply source code patches after extraction
if [ -f "$SOURCES/attr-2.5.2/tools/attr.c" ] && ! grep -q "libgen.h" "$SOURCES/attr-2.5.2/tools/attr.c"; then
    echo "Patching attr.c to include libgen.h"
    sed -i '1i #include <libgen.h>' "$SOURCES/attr-2.5.2/tools/attr.c"
fi

if [ -f "$SOURCES/libbsd-0.11.7/src/funopen.c" ] && ! grep -q "_LARGEFILE64_SOURCE" "$SOURCES/libbsd-0.11.7/src/funopen.c"; then
    echo "Patching funopen.c to define _LARGEFILE64_SOURCE"
    sed -i '1i #define _LARGEFILE64_SOURCE' "$SOURCES/libbsd-0.11.7/src/funopen.c"
fi

if [ -f "$SOURCES/acl-2.3.2/include/acl_ea.h" ] && ! grep -q "#include <features.h>" "$SOURCES/acl-2.3.2/include/acl_ea.h"; then
    echo "Patching acl_ea.h to include features.h for inline support"
    sed -i '1i #include <features.h>' "$SOURCES/acl-2.3.2/include/acl_ea.h"
fi

# Update CFLAGS in build scripts to ensure proper C standard is used
if [ -f "$REPO_ROOT/17-libacl-md-bsd.sh" ] && ! grep -q "-std=gnu99" "$REPO_ROOT/17-libacl-md-bsd.sh"; then
    echo "Updating CFLAGS in build scripts"
    sed -i 's/CFLAGS=\"\$CFLAGS/CFLAGS=\"\$CFLAGS -std=gnu99/g' "$REPO_ROOT/17-libacl-md-bsd.sh"
fi
