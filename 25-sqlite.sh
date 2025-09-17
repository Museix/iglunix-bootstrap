#!/bin/sh -e
[ -f "$REPO_ROOT/.sqlite" ] && exit 0
log() {
    echo "\033[0;32m[INFO]\033[0m $1"
}
export log
warn() {
    echo "\033[1;33m[WARN]\033[0m $1"
}
export warn
error() {
    echo "\033[0;31m[ERROR]\033[0m $1"
    exit 1
}
export error
log "building sqlite $SQLITE_VER"

mkdir -p "$BUILD/sqlite"
cd "$BUILD/sqlite"

"$SOURCES/sqlite-src-$SQLITE_VER_CODE/configure" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" DESTDIR="$SYSROOT" CC="$CC" CXX="$CXX" LD="ld.lld" \
    --prefix=/usr \
    --host="$TARGET" \
    --sysroot="$SYSROOT" \
    --tcl=no \
    --build=x86_64-unknown-linux-gnu 

bmake DESTDIR="$SYSROOT"  -j"$(nproc)"
bmake DESTDIR="$SYSROOT" install
touch "$REPO_ROOT/.sqlite"