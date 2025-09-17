# /etc/profile.d/colors.mksh - Color support for mksh
# This script sets up basic color support for ls and other commands

# Enable colors for ls if supported
if command -v ls >/dev/null 2>&1; then
    # Check if ls supports --color
    if ls --color=auto / >/dev/null 2>&1; then
        alias ls='ls --color=auto'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    elif ls -G / >/dev/null 2>&1; then
        # BSD-style ls
        alias ls='ls -G'
        export CLICOLOR=1
        export LSCOLORS='ExFxCxDxBxegedabagacad'
    fi
fi

# Set up basic LS_COLORS for GNU ls
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32'
