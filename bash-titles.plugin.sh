#!/usr/bin/env bash

# Set title with PS1 to be 'b:<path>'
if [[ -n "$TMUX" ]]; then
    PS1="\ekb:\w\e\a$PS1"
    PS1="\033]0;b:\w\a$PS1"
elif [[ $TERM =~ screen* ]]; then
    PS1="\ekb:\w\e\a$PS1"
    PS1="\033]0;b:\w\a$PS1"
elif [[ $TERM =~ xterm* ]]; then
    PS1="\033]0;b:\w\a$PS1"
elif [[ $TERM =~ ^rxvt-unicode.* ]]; then
    PS1="\33]2;b:\w\007$PS1"
fi
