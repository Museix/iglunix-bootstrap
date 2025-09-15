[ -f "$REPO_ROOT/.libedit" ] && exit 0

LIBEDIT_VER=3.1-20210112
LIBEDIT_SRC="$SOURCES/libedit-$LIBEDIT_VER"
LIBEDIT_BUILD="$BUILD/libedit-$LIBEDIT_VER"

echo "Building libedit $LIBEDIT_VER..."

# Create build directory
mkdir -p "$LIBEDIT_BUILD"
cd "$LIBEDIT_BUILD"
make -f "$LIBEDIT_SRC/Makefile" CC="$CC" all PREFIX="/usr" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
DESTDIR="$SYSROOT" make -f "$LIBEDIT_SRC/Makefile" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.libedit"