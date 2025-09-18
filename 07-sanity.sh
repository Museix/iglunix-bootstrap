#!/bin/sh -e

insane() {
	[ -f sanity ] && objdump -p sanity
	echo "Insane!"
	exit 0
}

./$ARCH-iglunix-linux-musl-c++.sh \
sanity.cpp -o sanity || insane

if [ ! -f "$REPO_ROOT/.zlib" ]; then
./15-zlib.sh
fi
if [ ! -f "$REPO_ROOT/.openssl" ]; then
./16-openssl.sh
fi
if [ ! -f "$REPO_ROOT/.cryptlib" ]; then
./17-cryptlib.sh
fi
if [ ! -f "$REPO_ROOT/.ncurses" ]; then
./18-ncurses.sh
fi
if [ ! -f "$REPO_ROOT/.libedit" ]; then
./19-libedit.sh
fi