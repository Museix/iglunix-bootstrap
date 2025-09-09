#!/bin/sh
[ -f "$REPO_ROOT/.perl" ] && exit 0

# Set up environment
SUDO_CMD="sudo"
SYSROOT="$REPO_ROOT/sysroot"
PERL_VER="5.42.0"
PERL_TAR="perl-${PERL_VER}.tar.gz"
PERL_URL="https://www.cpan.org/src/5.0/perl-${PERL_VER}.tar.gz"
BUILD_DIR="$SOURCES/perl-${PERL_VER}-build"

# Create build directory
echo '>>> Setting up build directory'
cd $SOURCES
rm -rf "perl-${PERL_VER}" "${BUILD_DIR}" "${PERL_TAR}"

# Install build dependencies if not already installed
if ! command -v gcc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
    echo '>>> Installing build dependencies'
    $SUDO_CMD pacman -S --noconfirm --needed base-devel gcc make
fi

# Download and extract Perl
echo '>>> Downloading Perl source'
wget -c "${PERL_URL}" -O "${PERL_TAR}"
tar xf "${PERL_TAR}"

# Create and enter build directory
mkdir -p "${BUILD_DIR}"
cd "${SOURCES}/perl-${PERL_VER}"

# Configure Perl build
echo '>>> Configuring Perl build'
./Configure \
    -des \
    -Dprefix=/usr \
    -Dcc=clang \
    -Dccflags="--sysroot=${SYSROOT} --target=x86_64-linux-musl -rtlib=compiler-rt -unwindlib=libunwind -stdlib=libc++ -Wno-unused-command-line-argument -fuse-ld=lld" \
    -Dldflags="--sysroot=${SYSROOT} -rtlib=compiler-rt -unwindlib=libunwind -stdlib=libc++ -fuse-ld=lld" \
    -Dusethreads \
    -Duseshrplib \
    -Dnoextensions=DB_File,GDBM_File,NDBM_File,ODBM_File \
    -Dnochown \
    -Dusenm=no \
    -Dcccdlflags="-fPIC" \
    -Dlddlflags="-shared" \
    -Dshrpdir="/usr/lib/perl5/${PERL_VER}/x86_64-linux-thread-multi/CORE" \
    -Darchlib="/usr/lib/perl5/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dvendorprefix=/usr \
    -Dvendorlib="/usr/share/perl5/vendor_perl" \
    -Dvendorarch="/usr/lib/perl5/vendor_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dsiteprefix=/usr \
    -Dsitelib="/usr/share/perl5/site_perl" \
    -Dsitearch="/usr/lib/perl5/site_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dman1dir="/usr/share/man/man1" \
    -Dman3dir="/usr/share/man/man3" \
    -Dsiteman1dir="/usr/share/man/man1" \
    -Dsiteman3dir="/usr/share/man/man3" \
    -Dman1ext="1" \
    -Dman3ext="3pm" \
    -Dpager="/usr/bin/less -isr" \
    -Dcf_by="iglunix-bootstrap" \
    -Dcf_email="root@localhost" \
    -Dcf_time="$(date +'%a %b %d %H:%M:%S %Z %Y')" \
    -Dmyhostname="localhost" \
    -Dperladmin="root@localhost" \
    -Dinstallusrbinperl=n \
    -Duselargefiles \
    -Dd_semctl_semun \
    -Di_db \
    -Ubincompat5005 \
    -Uversiononly \
    -Dpager="/usr/bin/less -isr" \
    -Dd_gethostent_r_proto=0 \
    -Ud_endhostent_r \
    -Ud_endprotoent_r \
    -Ud_endservent_r \
    -Ud_sethostent_r \
    -Ud_setprotoent_r \
    -Ud_setservent_r \
    -Ud_sockpair \
    -Ud_sockatmark \
    -Ud_sockatmark_proto=0 \
    -Ud_sockatmark_proto=0 \
    -Dscriptdir="/usr/bin" \
    -Dprivlib="/usr/share/perl5/core_perl" \
    -Darchlib="/usr/lib/perl5/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dvendorprefix="/usr" \
    -Dvendorlib="/usr/share/perl5/vendor_perl" \
    -Dvendorarch="/usr/lib/perl5/vendor_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dsiteprefix="/usr" \
    -Dsitelib="/usr/share/perl5/site_perl" \
    -Dsitearch="/usr/lib/perl5/site_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dman1dir="/usr/share/man/man1" \
    -Dman3dir="/usr/share/man/man3" \
    -Dsiteman1dir="/usr/share/man/man1" \
    -Dsiteman3dir="/usr/share/man/man3" \
    -Dman1ext="1" \
    -Dman3ext="3pm" \
    -Dpager="/usr/bin/less -isr" \
    -Dcf_by="iglunix-bootstrap" \
    -Dcf_email="root@localhost" \
    -Dcf_time="$(date +'%a %b %d %H:%M:%S %Z %Y')" \
    -Dmyhostname="localhost" \
    -Dperladmin="root@localhost" \
    -Dinstallusrbinperl=n \
    -Duselargefiles \
    -Dd_semctl_semun \
    -Di_db \
    -Ubincompat5005 \
    -Uversiononly \
    -Dpager="/usr/bin/less -isr" \
    -Dd_gethostent_r_proto=0 \
    -Ud_endhostent_r \
    -Ud_endprotoent_r \
    -Ud_endservent_r \
    -Ud_sethostent_r \
    -Ud_setprotoent_r \
    -Ud_setservent_r \
    -Ud_sockpair \
    -Ud_sockatmark \
    -Ud_sockatmark_proto=0 \
    -Ud_sockatmark_proto=0 \
    -Dscriptdir="/usr/bin" \
    -Dprivlib="/usr/share/perl5/core_perl" \
    -Darchlib="/usr/lib/perl5/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dvendorprefix="/usr" \
    -Dvendorlib="/usr/share/perl5/vendor_perl" \
    -Dvendorarch="/usr/lib/perl5/vendor_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dsiteprefix="/usr" \
    -Dsitelib="/usr/share/perl5/site_perl" \
    -Dsitearch="/usr/lib/perl5/site_perl/${PERL_VER}/x86_64-linux-thread-multi" \
    -Dman1dir="/usr/share/man/man1" \
    -Dman3dir="/usr/share/man/man3" \
    -Dsiteman1dir="/usr/share/man/man1" \
    -Dsiteman3dir="/usr/share/man/man3" \
    -Dman1ext="1" \
    -Dman3ext="3pm" \
    -Dpager="/usr/bin/less -isr"

# Build Perl
echo '>>> Building Perl'
make -j$(nproc)

# Install Perl
echo '>>> Installing Perl to sysroot'
$SUDO_CMD make DESTDIR="${SYSROOT}" install

# Create version file to prevent recompilation
touch "$REPO_ROOT/.perl"

echo '>>> Perl installation complete'
