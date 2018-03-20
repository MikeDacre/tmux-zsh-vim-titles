#!/bin/bash
# Default variables for tmux-zsh-vim-titles

#############
#  Control  #
#############

# Update the window name also
[ -n "$tmux_set_window_status" ] || tmux_set_window_status=false

# Use more CPU intensive vim title change
[ -n "$vim_force_tmux_title_change" ] || vim_force_tmux_title_change=false

#############
#  Formats  #
#############

## Tmux
[ -n "$tmux_title_start" ]      || tmux_title_start='t:'
[ -n "$tmux_title_root" ]       || tmux_title_root='rt:'

# tmux_title_format_ssh is used on SSH, but is used by get_hoststring.py
[ -n "$tmux_title_format" ]     || tmux_title_format='#S:#T'
[ -n "$tmux_title_format_ssh" ] || tmux_title_format_ssh='#h:#S:#T'

# For window names, if tmux_set_window_status is true, in tmux this is
# altered such that #W is replaced with #T (terminal title).
[ -n "$tmux_win_current_fmt" ]  || tmux_win_current_fmt='#F#I:#W'
[ -n "$tmux_win_other_fmt" ]    || tmux_win_other_fmt='#F#I:#W'

## ZSH
[ -n "$zsh_title_fmt" ]  || zsh_title_fmt='${cmd}:${pth}'
# Space taken by the path in the title bar
[ -n "$pth_width" ]      || pth_width=60
# Space taken by the path in the window tab, if tmux_set_window_status is true
[ -n "$win_pth_width" ]  || win_pth_width=25

## Vim
[ -n "$vim_title_prefix" ] || vim_title_prefix="v:"
[ -n "$vim_include_path" ] || vim_include_path=false  # Can be true or 'long'
