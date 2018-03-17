#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Try to correctly set titles
tmux set -g set-titles on

main() {
    # Get default starting strings
    # tmux_title_format_ssh is used on SSH, but is used by get_hoststring.py
    [ -n "$tmux_title_start" ]      || tmux_title_start='t:'
    [ -n "$tmux_title_root" ]       || tmux_title_root='rt:'
    [ -n "$tmux_title_format" ]     || tmux_title_format='#S:#T'
    [ -n "$tmux_title_format_ssh" ] || tmux_title_format_ssh='#h:#S:#T'
    [ -n "$tmux_win_current_fmt" ]  || tmux_win_current_fmt='#I:#W#F'
    [ -n "$tmux_win_other_fmt" ]    || tmux_win_other_fmt='#I:#W#F'

    if [[ "${USER}" == 'root' ]]; then
        tmux_string="${tmux_title_root}"
    else
        tmux_string="${tmux_title_start}"
    fi
    # Detect if we are in an SSH session
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        tmux_string="${tmux_string}$(${CURRENT_DIR}/scripts/get_hoststring.py)"
    else
        tmux_string="${tmux_string}${tmux_title_format}"
    fi
    tmux set -g set-titles-string "${tmux_string}"

    if [ -n "$tmux_set_window_status" ]; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set)
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
            tmux set-option -gq @win-status-set 'true'
        fi
        tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
        tmux set-option -g automatic-rename-format "${tmux_win_other_fmt}"
    fi
}
main
