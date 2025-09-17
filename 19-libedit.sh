[ -f "$REPO_ROOT/.libedit" ] && exit 0

LIBEDIT_SRC="$SOURCES/libedit"
cd "$LIBEDIT_SRC"
make -f "$LIBEDIT_SRC/Makefile" CC="$CC" all PREFIX="/usr" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
DESTDIR="$SYSROOT" PREFIX="/usr" make -f "$LIBEDIT_SRC/Makefile" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.libedit"
