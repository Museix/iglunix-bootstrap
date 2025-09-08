#!/bin/sh -e
[ -f "$REPO_ROOT/.bmake" ] && exit 0
if ! command -v bmake >/dev/null 2>&1; then
echo 'YOU MUST HAVE BMAKE INSTALLED ON YOUR HOST TO BOOTSTRAP BMAKE' && exit 1
fi
SUDO_CMD="sudo"


echo

echo '>>> Building bmake'
echo

cd $SOURCES/bmake

echo '>>> Building bmake'
CFLAGS="$CFLAGS --target=$TARGET" bmake
CFLAGS="$CFLAGS --target=$TARGET" $SUDO_CMD PREFIX=/usr/ DESTDIR=$SYSROOT bmake install

touch $REPO_ROOT/.bmake
