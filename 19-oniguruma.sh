#!/bin/sh -e
[ -f "$REPO_ROOT/.oniguruma" ] && exit 0

echo ">>> building oniguruma"

cd "$BUILD"
rm -rf onig-$ONIGURUMA_VER
tar -xf "$SOURCES/onig-$ONIGURUMA_VER.tar.gz"
cd onig-$ONIGURUMA_VER

./configure --prefix=/usr --host=$TARGET
make -j$(nproc)
make DESTDIR=$SYSROOT install

touch $REPO_ROOT/.oniguruma
