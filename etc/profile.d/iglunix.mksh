# /etc/profile.d/iglunix.mksh - Iglunix-specific environment settings
# This script sets up Iglunix-specific environment variables and settings

# Set Iglunix-specific environment variables
export IGLUNIX_VERSION="1.0"
export IGLUNIX_ARCH="$(uname -m)"

# Prefer Iglunix tools over GNU equivalents
export CC="clang"
export CXX="clang++"
export MAKE="bmake"
export YACC="byacc"
export LEX="flex"

# Set up library paths for musl and LLVM
export LIBRARY_PATH="/usr/lib:/usr/local/lib"
export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib"

# Configure pkg-config to use pkgconf
export PKG_CONFIG="pkgconf"

# Set up man page paths
export MANPATH="/usr/share/man:/usr/local/share/man"

# Configure less pager
export LESS="-R -M --shift 5"
export LESSCHARSET="utf-8"

# Set up locale (minimal for Iglunix)
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
