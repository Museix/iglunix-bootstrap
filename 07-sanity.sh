#!/bin/sh -e

insane() {
	[ -f sanity ] && objdump -p sanity
	echo "Insane!"
	exit 1
}

./$ARCH-iglunix-linux-musl-c++.sh \
sanity.cpp -o sanity || insane

LD_LIBRARY_PATH=$(pwd)/sysroot/usr/lib qemu-$ARCH ./sysroot/usr/lib/libc.so ./sanity || insane
if [ -f "$REPO_ROOT/.zlib" ]; then
./15-zlib.sh
fi
if [ -f "$REPO_ROOT/.openssl" ]; then
./16-openssl.sh
fi
if [ -f "$REPO_ROOT/.cryptlib" ]; then
./17-cryptlib.sh
fi
if [ -f "$REPO_ROOT/.ncurses" ]; then
./18-ncurses.sh
fi
