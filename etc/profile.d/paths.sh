# /etc/profile.d/paths.mksh - Path management for mksh
# This script provides path manipulation functions compatible with mksh

# Function to append to PATH if directory exists and is not already in PATH
pathappend() {
    if [ -d "$1" ] && [ -n "$1" ]; then
        case ":$PATH:" in
            *":$1:"*) ;;
            *) PATH="$PATH:$1" ;;
        esac
    fi
}

# Function to prepend to PATH if directory exists and is not already in PATH
pathprepend() {
    if [ -d "$1" ] && [ -n "$1" ]; then
        case ":$PATH:" in
            *":$1:"*) ;;
            *) PATH="$1:$PATH" ;;
        esac
    fi
}

# Add common extra paths
pathappend /usr/local/sbin
pathappend /usr/local/bin
pathappend /usr/games
pathappend /snap/bin

# Export the updated PATH
export PATH
