# /etc/profile.d/umask.mksh - Set umask for mksh
# This script sets appropriate umask values

# Set umask based on user ID
if [ "$(id -u)" -eq 0 ]; then
    # Root user - more restrictive
    umask 022
else
    # Regular users
    if [ "$(id -u)" -ge 1000 ]; then
        # Regular user accounts
        umask 022
    else
        # System accounts
        umask 027
    fi
fi
