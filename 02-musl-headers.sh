#!/bin/sh -e
[ -f "$REPO_ROOT/.musl-headers" ] && exit 0

cd $SOURCES/musl-$MUSL_VER

# Apply security patches
for patch in "$REPO_ROOT/patches/musl/musl-"*.patch; do
    echo "Applying patch: $(basename "$patch")"
    patch -p1 < "$patch"
done

./configure --prefix=/usr --target=$TARGET

$MAKE DESTDIR=$SYSROOT install-headers

touch $REPO_ROOT/.musl-headers
