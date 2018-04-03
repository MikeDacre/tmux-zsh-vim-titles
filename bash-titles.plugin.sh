#!/usr/bin/env bash

[ -n "$HOSTNAME" ] || HOSTNAME=$(uname -n | sed 's/\..*//g')

# Set title with PS1 to be 'b:<path>'
if [ -n "$TMUX" ]; then
    PS1="\ekb:${HOSTNAME}:\w\e\a$PS1"
    PS1="\033]0;b:${HOSTNAME}:\w\a$PS1"
elif [[ $TERM =~ screen* ]]; then
    PS1="\ekb:${HOSTNAME}:\w\e\a$PS1"
    PS1="\033]0;b:${HOSTNAME}:\w\a$PS1"
elif [[ $TERM =~ xterm* ]]; then
    PS1="\033]0;b:${HOSTNAME}:\w\a$PS1"
elif [[ $TERM =~ ^rxvt-unicode.* ]]; then
    PS1="\33]2;b:${HOSTNAME}:\w\007$PS1"
fi
