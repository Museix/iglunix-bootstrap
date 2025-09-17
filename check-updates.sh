#!/bin/sh

# This script checks for updates to the components used in the bootstrap process.
# It reads the current versions from boot.sh and compares them to the latest
# available versions from their sources.

set -e

CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
BOOT_SCRIPT="$CURRENT_DIR/boot.sh"

if [ ! -f "$BOOT_SCRIPT" ]; then
    echo "Error: boot.sh not found in the same directory as this script." >&2
    exit 1
fi

# --- Helper Functions ---

get_current_version() {
    grep "export $1=" "$BOOT_SCRIPT" | cut -d'=' -f2
}

print_status() {
    component=$1
    current=$2
    latest=$3

    if [ -z "$latest" ] || [ "$latest" = "null" ]; then
        printf "%-15s | %-15s | %s\n" "$component" "$current" "Failed to get latest version"
        return
    fi

    if [ "$current" = "$latest" ]; then
        printf "%-15s | %-15s | %s\n" "$component" "$current" "Up to date"
    else
        printf "%-15s | %-15s | \033[1;33mUpdate available: %s\033[0m\n" "$component" "$current" "$latest"
    fi
}

check_github_release() {
    repo=$1
    component_name=$2
    current_version=$(get_current_version "$3")

    latest_version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    print_status "$component_name" "$current_version" "$latest_version"
}

check_github_tag() {
    repo=$1
    component_name=$2
    current_version=$(get_current_version "$3")
    prefix=${4:-""}
    suffix=${5:-""}

    latest_version=$(curl -s "https://api.github.com/repos/$repo/tags" | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed -n "s/^${prefix}//;s/${suffix}$//p" | sort -V | tail -n 1)

    print_status "$component_name" "$current_version" "$latest_version"
}


# --- Main Update Checks ---

echo "Checking for component updates..."
printf "%-15s | %-15s | %s\n" "Component" "Current" "Status"
echo "-----------------------------------------------------"

# LLVM
LLVM_VER=$(get_current_version LLVM_VER)
LATEST_LLVM=$(curl -s "https://api.github.com/repos/llvm/llvm-project/releases" | grep '"tag_name":' | sed -E 's/.*"llvmorg-([^"]+)".*/\1/' | grep -v -- '-rc' | sort -V | tail -n 1)
print_status "LLVM" "$LLVM_VER" "$LATEST_LLVM"

# musl
MUSL_VER=$(get_current_version MUSL_VER)
LATEST_MUSL=$(curl -s "https://musl.libc.org/releases/" | grep -o 'musl-[0-9.]*\.tar\.gz' | sed 's/musl-\(.*\)\.tar\.gz/\1/' | sort -V | tail -n 1)
print_status "musl" "$MUSL_VER" "$LATEST_MUSL"

# Linux Kernel
KERN_VER=$(get_current_version KERN_VER)
LATEST_KERN=$(curl -s "https://www.kernel.org/releases.json" | grep '"version":' | sed -E 's/.*"version": "([^"]+)".*/\1/' | head -n 1)
print_status "Kernel" "$KERN_VER" "$LATEST_KERN"

# mksh
MKSH_VER=$(get_current_version MKSH_VER)
LATEST_MKSH=$(curl -s "https://www.mirbsd.org/mksh.htm" | grep -o 'mksh-R[0-9]*[a-z]*\.tgz' | sed -e 's/mksh-\(R[0-9]*[a-z]*\)\.tgz/\1/' | sort -V | tail -n 1)
print_status "mksh" "$MKSH_VER" "$LATEST_MKSH"

# GNU Make
GMAKE_VER=$(get_current_version GMAKE_VER)
LATEST_GMAKE=$(curl -s "https://ftp.gnu.org/gnu/make/" | grep -o 'make-[0-9.]*\.tar\.gz' | sed 's/make-\(.*\)\.tar\.gz/\1/' | sort -V | tail -n 1)
print_status "GNU Make" "$GMAKE_VER" "$LATEST_GMAKE"

# zlib-ng
check_github_release "zlib-ng/zlib-ng" "zlib-ng" "ZLIB_NG_VER"

# OpenSSL
OPENSSL_VER=$(get_current_version OPENSSL_VER)
LATEST_OPENSSL=$(curl -s "https://www.openssl.org/source/" | grep -o 'openssl-[0-9.]*[a-z]*\.tar\.gz' | sed 's/openssl-\(.*\)\.tar\.gz/\1/' | sort -V | tail -n 1)
print_status "OpenSSL" "$OPENSSL_VER" "$LATEST_OPENSSL"

# cryptlib
check_github_tag "cryptlib/cryptlib" "cryptlib" "CRYPTLIB_VER" "v"

# ncurses
NCURSES_VER=$(get_current_version NCURSES_VER)
LATEST_NCURSES=$(curl -s "https://invisible-mirror.net/archives/ncurses/" | grep -o 'ncurses-[0-9.]*\.tar\.gz' | sed 's/ncurses-\(.*\)\.tar\.gz/\1/' | sort -V | tail -n 1)
print_status "ncurses" "$NCURSES_VER" "$LATEST_NCURSES"

# oniguruma
check_github_release "kkos/oniguruma" "oniguruma" "ONIGURUMA_VER"

# Rust
RUST_VER=$(get_current_version RUST_VER)
LATEST_RUST=$(curl -s "https://api.github.com/repos/rust-lang/rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
print_status "Rust" "$RUST_VER" "$LATEST_RUST"

# uutils-coreutils
check_github_tag "uutils/coreutils" "uutils" "UUTILS_VER"

# util-linux
UTIL_LINUX_VER=$(get_current_version UTIL_LINUX_VER)
LATEST_UTIL_LINUX=$(curl -s "https://www.kernel.org/pub/linux/utils/util-linux/" | grep -o 'v[0-9.]*/' | sed 's/v\(.*\)\//\1/' | sort -V | tail -n 1)
LATEST_UTIL_LINUX_SUB=$(curl -s "https://www.kernel.org/pub/linux/utils/util-linux/v${LATEST_UTIL_LINUX}/" | grep -o "util-linux-${LATEST_UTIL_LINUX}.[0-9]*\.tar.gz" | sed -E "s/util-linux-(${LATEST_UTIL_LINUX}.[0-9]*).tar.gz/\1/" | sort -V | tail -n 1)
if [ -z "$LATEST_UTIL_LINUX_SUB" ]; then
    LATEST_UTIL_LINUX_SUB=$LATEST_UTIL_LINUX
fi
print_status "util-linux" "$UTIL_LINUX_VER" "$LATEST_UTIL_LINUX_SUB"

# dash
DASH_VER=$(get_current_version DASH_VER)
LATEST_DASH=$(curl -s "https://git.kernel.org/pub/scm/utils/dash/dash.git/refs/tags" | grep -o 'dash-[0-9.]*\.tar\.gz' | sed 's/dash-\(.*\)\.tar\.gz/\1/' | sort -V | tail -n 1)
print_status "dash" "$DASH_VER" "$LATEST_DASH"

# libexecinfo
check_github_release "fam007e/libexecinfo" "libexecinfo" "LIBEXECINFO_VER"

# pkgconf
PKGCONF_VER=$(get_current_version PKGCONF_VER)
LATEST_PKGCONF=$(curl -s "https://distfiles.dereferenced.org/pkgconf/" | grep -o 'pkgconf-[0-9.]*\.tar\.xz' | sed 's/pkgconf-\(.*\)\.tar\.xz/\1/' | sort -V | tail -n 1)
print_status "pkgconf" "$PKGCONF_VER" "$LATEST_PKGCONF"

# sqlite
SQLITE_VER=$(get_current_version SQLITE_VER)
LATEST_SQLITE_YEAR=$(date +%Y)
LATEST_SQLITE_CODE=$(curl -s "https://sqlite.org/${LATEST_SQLITE_YEAR}/" | grep -o 'sqlite-src-[0-9]*\.zip' | sed 's/sqlite-src-\([0-9]*\)\.zip/\1/' | sort -n | tail -n 1)
LATEST_SQLITE_VER=$(echo "$LATEST_SQLITE_CODE" | sed -E 's/(.)(..)(..)../\1.\2.\3/')
print_status "sqlite" "$SQLITE_VER" "$LATEST_SQLITE_VER"

echo "-----------------------------------------------------"
echo "Update check complete." && touch $REPO_ROOT/.update && exit 0