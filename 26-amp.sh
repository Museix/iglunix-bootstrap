#!/bin/sh -e
[ -f "$REPO_ROOT/.amp" ] && { echo "aee already built. Remove $REPO_ROOT/.amp to rebuild."; exit 0; }

echo "\n>>> Building aee $AEE_VER"
echo "========================================"

# Ensure source directory exists
if [ ! -d "$SOURCES/aee-$AEE_VER" ]; then
    echo "Error: Source directory not found: $SOURCES/aee-$AEE_VER"
    exit 1
fi
mkdir -p "$BUILD/aee-$AEE_VER"
cd "$BUILD/aee-$AEE_VER"
[ ! -f "$SYSROOT/usr/lib/libcurses.so" ] && ln -s $SYSROOT/usr/lib/libncursesw.so $SYSROOT/usr/lib/libcurses.so
[ ! -f "$SYSROOT/usr/lib/libcursesw.so" ] && ln -s $SYSROOT/usr/lib/libncursesw.so $SYSROOT/usr/lib/libcursesw.so
[ ! -f "$SYSROOT/usr/lib/libcurses.a" ] && ln -s $SYSROOT/usr/lib/libncursesw.a $SYSROOT/usr/lib/libcurses.a
[ ! -f "$SYSROOT/usr/lib/libcursesw.a" ] && ln -s $SYSROOT/usr/lib/libncursesw.a $SYSROOT/usr/lib/libcursesw.a
# Build with ninja
cmake -B . -G 'Unix Makefiles' -S "$SOURCES/aee" -DCMAKE_SYSROOT=$SYSROOT -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=$CC -DCMAKE_C_FLAGS="$CFLAGS -std=c89 -Wno-int-conversion -Wno-format-security -Wno-unused-result" -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_SYSROOT=$SYSROOT -DCMAKE_INSTALL_PREFIX=/usr
make 
DESTDIR=$SYSROOT make install

# Create version file to prevent recompilation
touch $REPO_ROOT/.amp