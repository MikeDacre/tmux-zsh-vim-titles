#!/usr/bin/env bash

# Try to correctly set titles
tmux set -g set-titles on

# Get default starting strings
[ -n "$tmux_title_start" ]      || tmux_title_start='t:'
[ -n "$tmux_title_root" ]       || tmux_title_root='rt:'
[ -n "$tmux_title_format" ]     || tmux_title_format='#S:#T'
[ -n "$tmux_title_format_ssh" ] || tmux_title_format_ssh='#h:#S:#T'
[ -n "$tmux_win_current_fmt" ]  || tmux_win_current_fmt='#I:#T'
[ -n "$tmux_win_other_fmt" ]    || tmux_win_other_fmt='#I:#T'

if [[ "${USER}" == 'root' ]]; then
    tmux_string="${tmux_title_root}"
else
    tmux_string="${tmux_title_start}"
fi
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    tmux_string="${tmux_string}${tmux_title_format_ssh}"
else
    tmux_string="${tmux_string}${tmux_title_format}"
fi
tmux set -g set-titles-string "${tmux_string}"

if [ -z "$tmux_no_set_window_status" ]; then
    tmux set-window-option -g window-status-current-format "#I:#T"
    tmux set-window-option -g window-status-format "#I:#T"
fi
tmux set-window-option -g automatic-rename on
