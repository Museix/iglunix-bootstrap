#!/bin/sh -e
[ -f "$REPO_ROOT/.musl-standalone" ] && exit 0

echo ">>> building musl-standalone components"

# Common configure and build function
build_component() {
    local name=$1
    local src_dir="$SOURCES/musl-standalone/$name"
    local build_dir="$BUILD/musl-standalone/$name"
    
    echo "=== Building $name ==="
    mkdir -p "$build_dir"
    cd "$src_dir"
    
    # Run bootstrap if it exists
    [ -f "./bootstrap" ] && ./bootstrap
    [ -f "./autogen.sh" ] && ./autogen.sh
    
    cd "$build_dir"
    
    "$src_dir/configure" \
        --prefix=/usr \
        --host=$TARGET \
        --disable-shared \
        --enable-static \
        --with-sysroot="$SYSROOT" \
        CC="$CC" \
        CFLAGS="$CFLAGS -I$SYSROOT/usr/include" \
        LDFLAGS="$LDFLAGS -L$SYSROOT/usr/lib"
    
    make -j$(nproc)
    make DESTDIR="$SYSROOT" install
}

# Build musl-fts
build_component "musl-fts"

# Build musl-obstack
build_component "musl-obstack"

# Build musl-nscd (if needed)
if [ -d "$SOURCES/musl-standalone/musl-nscd" ]; then
    echo "=== Building musl-nscd ==="
    cd "$SOURCES/musl-standalone/musl-nscd"
    make -j$(nproc) \
        CC="$CC" \
        CFLAGS="$CFLAGS -I$SYSROOT/usr/include" \
        LDFLAGS="$LDFLAGS -L$SYSROOT/usr/lib" \
        PREFIX=/usr \
        DESTDIR="$SYSROOT"
    make PREFIX=/usr DESTDIR="$SYSROOT" install
fi

# Create a file to mark this as built
touch "$REPO_ROOT/.musl-standalone"

echo "<<< musl-standalone components built successfully"
