#!/bin/sh -e

insane() {
	[ -f sanity ] && objdump -p sanity
	echo "Insane!"
	exit 1
}

./$ARCH-museix-linux-musl-c++.sh \
sanity.cpp -o sanity || insane

LD_LIBRARY_PATH=$(pwd)/sysroot/usr/lib qemu-$ARCH ./sysroot/usr/lib/libc.so ./sanity || insane
