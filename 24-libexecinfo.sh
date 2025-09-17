#!/bin/sh -e
[ -f "$REPO_ROOT/.libexecinfo" ] && exit 0
cd $SOURCES/libexecinfo

echo '>>> Configuring libexecinfo'
DESTDIR="$SYSROOT" make \
    CC="$CC" \
    CFLAGS="-target $TARGET $CFLAGS -fPIC" \
    LDFLAGS="-target $TARGET $LDFLAGS" \
    PREFIX=/usr 


# Install to sysroot
make PREFIX=/usr all  DESTDIR="$SYSROOT" install

# Create version file to prevent recompilation
touch $REPO_ROOT/.libexecinfo
