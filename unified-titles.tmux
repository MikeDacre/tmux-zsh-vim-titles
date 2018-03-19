#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Attempt to get all applicable profiles
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.tmux/profile" ]; then
    source "$HOME/.tmux/profile" 2>/dev/null >/dev/null
fi

TMUX_CONF=$(tmux show-option -gqv @tmux_conf | tr -d "[:space:]")
if [ -f "$TMUX_CONF" ]; then
    source "$TMUX_CONF" 2>/dev/null >/dev/null
fi

# Try to correctly set titles
tmux set -g set-titles on

main() {
    # Get default starting strings
    # tmux_title_format_ssh is used on SSH, but is used by get_hoststring.py
    [ -n "$tmux_title_start" ]      || tmux_title_start='t:'
    [ -n "$tmux_title_root" ]       || tmux_title_root='rt:'
    [ -n "$tmux_title_format" ]     || tmux_title_format='#S:#T'
    [ -n "$tmux_title_format_ssh" ] || tmux_title_format_ssh='#h:#S:#T'
    [ -n "$tmux_win_current_fmt" ]  || tmux_win_current_fmt='#F#I:#W'
    [ -n "$tmux_win_other_fmt" ]    || tmux_win_other_fmt='#F#I:#W'

    local tmux_start_str
    local tmux_string

    if [[ "${USER}" == 'root' ]]; then
        tmux_start_str="${tmux_title_root}"
    else
        tmux_start_str="${tmux_title_start}"
    fi

    # Detect if we are in an SSH session, use script to munge tmux_title_format_ssh
	# if we are, else just use the simple title format
    # Note: SSH_TTY and SSH_CLIENT remain set by children of tmux if tmux started by an
    # SSH session, SSH_CONNECTION is reset though. The below test allows us to know if
    # we are currently accessing the terminal via SSH or not.
    if [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        tmux_string="${tmux_start_str}$(${CURRENT_DIR}/scripts/get_hoststring.py | tr -d '[:space:]')"
        tmux set-option -gq @ssh-session-info "${SSH_CONNECTION}"
    else
        tmux_string="${tmux_start_str}${tmux_title_format}"
        tmux set-option -gq @ssh-session-info ""
    fi

	# Actually set the title
    tmux set -g set-titles-string "${tmux_string}"

    if [ -n "$tmux_set_window_status" ]; then
        tmux set-option -gq @tmux_set_window_status 'true'
    fi

    if [[ $(tmux show-option -gqv @tmux_set_window_status | tr -d "[:space:]") == 'true' ]]; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set | tr -d "[:space:]")
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
            tmux set-option -gq @win-status-set 'true'
        fi
        tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
    fi
}
main
