#!/bin/sh -e
[ -f "$REPO_ROOT/.dash" ] && exit 0

echo ">>> building dash"

cd "$BUILD"
rm -rf dash-$DASH_VER
tar -xf "$SOURCES/dash-$DASH_VER.tar.gz"
cd dash-$DASH_VER
./autogen.sh
./configure --prefix=/usr --host=$TARGET
make -j$(nproc)
make DESTDIR=$SYSROOT install

touch $REPO_ROOT/.dash
