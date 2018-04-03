#!/usr/bin/env bash
# Path to config file, to create one, just make a copy of this file
# at your $tzvt_config location (e.g. ~/.tzvt_config
if [ -z "$tzvt_config" ]; then
    if [ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null; then
        tzvt_config=$(tmux show-option -gqv @tzvt_config | tr -d "[:space:]")
    fi
    if [ -z "$tzvt_config" ]; then
        if [ -f "$HOME/.tzvt_config" ]; then
            tzvf_config="$HOME/.tzvt_config"
        elif [ -f "${tzvt_tmux}/profile.sh" ]; then
            tzvt_config="${tzvt_tmux}/profile.sh"
        fi
    fi
fi

if [ -f "$tzvt_config" ]; then
    source "$tzvt_config"
fi
