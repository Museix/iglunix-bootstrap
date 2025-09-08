#!/bin/sh -e
[ -f "$REPO_ROOT/.doas" ] && exit 0
SUDO_CMD="sudo"

echo '>>> Downloading and building OpenDoas with configuration directory support'
cd $SOURCES

# Clean up any previous build
rm -rf opendoas-6.8.2 opendoas-6.8.2.tar.xz

# Download OpenDoas
wget -c https://github.com/Duncaen/OpenDoas/releases/download/v6.8.2/opendoas-6.8.2.tar.xz
mkdir -p opendoas-6.8.2
cd opendoas-6.8.2
tar xf ../opendoas-6.8.2.tar.xz --strip-components=1

# Apply patches
echo '>>> Applying patches'

# Create musl-compat.h in the source directory
cat > musl-compat.h << 'EOF'
#ifndef MUSL_COMPAT_H
#define MUSL_COMPAT_H

#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <stdio.h>

#ifndef UID_MAX
#define UID_MAX 0xffffffff
#endif

#ifndef GID_MAX
#define GID_MAX 0xffffffff
#endif

/* Only define execvpe if it's not already defined */
#ifndef HAVE_EXECVPE
static int execvpe(const char *file, char *const argv[], char *const envp[]) {
    char *path, *p, *next, *path_tmp;
    size_t len;
    char buf[4096];
    
    if (strchr(file, '/') != NULL)
        return execve(file, argv, envp);

    path = getenv("PATH");
    if (!path)
        path = "/bin:/usr/bin:/usr/local/bin";

    path_tmp = strdup(path);
    if (!path_tmp)
        return -1;

    for (p = path_tmp; p; p = next) {
        next = strchr(p, ':');
        if (next)
            *next++ = '\0';

        len = strlen(p) + 1 + strlen(file) + 1;
        if (len > sizeof(buf)) {
            errno = ENAMETOOLONG;
            continue;
        }

        snprintf(buf, sizeof(buf), "%s/%s", p, file);
        execve(buf, argv, envp);
        
        if (errno != ENOENT && errno != ENOTDIR) {
            free(path_tmp);
            return -1;
        }
    }
    
    free(path_tmp);
    errno = ENOENT;
    return -1;
}
#endif /* !HAVE_EXECVPE */

#endif /* MUSL_COMPAT_H */
EOF


# Apply UID_MAX/GID_MAX and execvpe fixes
cat > musl-fix.patch << 'EOF'
--- a/doas.c
+++ b/doas.c
@@ -1,4 +1,5 @@
 #include <sys/types.h>
+#include "musl-compat.h"
 #include <sys/stat.h>
 #include <sys/wait.h>
 #include <sys/ioctl.h>
@@ -8,7 +15,6 @@
 #include <string.h>
 #include <unistd.h>
 #include <pwd.h>
-#include <limits.h>
 #include <errno.h>
 #include <fcntl.h>
 #include <time.h>
@@ -16,6 +22,8 @@
 #include "openbsd.h"
 #include "doas.h"
 
+#include "musl-compat.h"
+
 #ifdef HAVE_BSD_AUTH_H
 #include <login_cap.h>
 #include <bsd_auth.h>
@@ -503,9 +511,15 @@
 					errx(1, "execv %s", cmd);
 		}
 		err(1, "execv %s", cmd);
-	}
-
-	return 0;
+    } else {
+        if (envp) {
+            execvpe(cmd, argv, envp);
+        } else {
+            execvp(cmd, argv);
+        }
+        err(1, "execv %s", cmd);
+    }
+    return 0;
 }
EOF

patch -p1 < musl-fix.patch || echo '>>> Warning: musl-fix.patch failed to apply'

# Configuration directory patch
if [ -f "$REPO_ROOT/opendoas-configuration-directory.patch" ]; then
    echo '>>> Applying configuration directory patch'
    patch -p1 < "$REPO_ROOT/opendoas-configuration-directory.patch" || echo '>>> Warning: opendoas-configuration-directory.patch failed to apply'
fi

# PATH modification patch
if [ -f "$REPO_ROOT/opendoas-change-PATH.patch" ]; then
    echo '>>> Applying PATH modification patch'
    patch -p1 < "$REPO_ROOT/opendoas-change-PATH.patch" || echo '>>> Warning: opendoas-change-PATH.patch failed to apply'
fi

# Rowhammer protection patch
if [ -f "$REPO_ROOT/opendoas-rowhammer.patch" ]; then
    echo '>>> Applying rowhammer protection patch'
    patch -p1 < "$REPO_ROOT/opendoas-rowhammer.patch" || echo '>>> Warning: opendoas-rowhammer.patch failed to apply'
fi

# Musl compatibility fix
if [ -f "$REPO_ROOT/opendoas-musl-fix.patch" ]; then
    echo '>>> Applying musl compatibility fix'
    patch -p1 < "$REPO_ROOT/opendoas-musl-fix.patch" || echo '>>> Warning: opendoas-musl-fix.patch failed to apply'
fi

# Configure the project first to generate Makefile
./configure --prefix=/usr --with-pam --with-timestamp

sed -i 's|^CFLAGS =|CFLAGS = -I.|' GNUmakefile

# Build doas
echo '>>> Building OpenDoas'
CC="$CC" \
CFLAGS="$CFLAGS -fPIE -I." \
LDFLAGS="-static -pie" \
make -j$(nproc)

# Install doas
echo '>>> Installing OpenDoas'
$SUDO_CMD make DESTDIR="$SYSROOT" install

# Create configuration directory
$SUDO_CMD mkdir -p "$SYSROOT/etc/doas.d"
$SUDO_CMD chmod 755 "$SYSROOT/etc/doas.d"

# Create basic doas.conf if it doesn't exist
if [ ! -f "$SYSROOT/etc/doas.conf" ]; then
    echo '>>> Creating default doas.conf'
    $SUDO_CMD tee "$SYSROOT/etc/doas.conf" > /dev/null << 'EOF'
# doas configuration for Iglunix
# Allow members of wheel group to execute any command
permit persist :wheel

# Allow root to execute any command without password
permit nopass keepenv root
EOF
fi

# Set proper permissions
$SUDO_CMD chmod 4755 "$SYSROOT/usr/bin/doas"
$SUDO_CMD chmod 600 "$SYSROOT/etc/doas.conf"

# Create PAM configuration for doas
$SUDO_CMD mkdir -p "$SYSROOT/etc/pam.d"
$SUDO_CMD tee "$SYSROOT/etc/pam.d/doas" > /dev/null << 'EOF'
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOF

# Create a marker file to indicate successful installation
touch "$REPO_ROOT/.doas"

echo '>>> OpenDoas installation complete with configuration directory support'

make -j$(nproc)

# Install doas
echo '>>> Installing OpenDoas'
$SUDO_CMD make DESTDIR="$SYSROOT" install

# Create basic doas configuration
echo '>>> Configuring doas'
$SUDO_CMD mkdir -p "$SYSROOT/etc"
$SUDO_CMD tee "$SYSROOT/etc/doas.conf" > /dev/null << 'EOF'
# doas configuration for Iglunix
# Allow members of wheel group to execute any command
permit persist :wheel

# Allow root to execute any command without password
permit nopass keepenv root
EOF

# Create configuration directory
$SUDO_CMD mkdir -p "$SYSROOT/etc/doas.d"
$SUDO_CMD chmod 755 "$SYSROOT/etc/doas.d"

# Create PAM configuration for doas
$SUDO_CMD mkdir -p "$SYSROOT/etc/pam.d"
$SUDO_CMD tee "$SYSROOT/etc/pam.d/doas" > /dev/null << 'EOF'
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOF

# Set proper permissions
$SUDO_CMD chmod 4755 "$SYSROOT/usr/bin/doas"
$SUDO_CMD chmod 600 "$SYSROOT/etc/doas.conf"

# Create a marker file to indicate successful installation
touch "$REPO_ROOT/.doas"

echo '>>> OpenDoas installation complete with configuration directory support'

# Create version file to prevent recompilation
touch $REPO_ROOT/.doas

echo '>>> doas installed successfully'
