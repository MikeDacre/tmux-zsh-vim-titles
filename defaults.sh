#!/bin/bash
# Default variables for tmux-zsh-vim-titles

#############
#  Control  #
#############

# Path to config file, to create one, just make a copy of this file
# at your $tzvt_config location (e.g. ~/.tzvt_config
[ -n "$tzvt_config" ] || tzvt_config="$HOME/.tzvt_config"

# Update tmux title on zsh shell change
[ -n "$tzvt_zsh_update_tmux" ] || tzvt_zsh_update_tmux=false

# Update the window name also
[ -n "$tzvt_set_tmux_window_status" ] || tzvt_set_tmux_window_status=false

# Use more CPU intensive vim title change
[ -n "$tzvt_vim_force_tmux_title_change" ] || tzvt_vim_force_tmux_title_change=false

#############
#  Formats  #
#############

## Hostname, JSON dictionary, e.g.:
## tzvt_host_dict="{$HOST: 'mycomp'}" Used to replace hostname
## wherever host name is used
[ -n "$tzvt_host_dict" ] || tzvt_host_dict=""

# Space taken by the path in the title bar
[ -n "$tzvt_pth_width" ]      || tzvt_pth_width=60
# Space taken by the path in the window tab, if tzvt_set_tmux_window_status is true
[ -n "$tzvt_win_pth_width" ]  || tzvt_win_pth_width=25

## Tmux
[ -n "$tzvt_tmux_title_start" ]      || tzvt_tmux_title_start='t:'
[ -n "$tzvt_tmux_title_root" ]       || tzvt_tmux_title_root='rt:'

# tzvt_tmux_title_format_ssh is used on SSH, and is parsed to use
# the shortest hostname possible. For the long hostname, use #H or set $HOSTNAME
[ -n "$tzvt_tmux_title_format" ]     || tzvt_tmux_title_format='#S:#T'
[ -n "$tzvt_tmux_title_format_ssh" ] || tzvt_tmux_title_format_ssh='#h:#S:#T'

# For window names, if tzvt_set_tmux_window_status is true, in tmux this is
# altered such that #W is replaced with #T (terminal title).
[ -n "$tzvt_tmux_win_current_fmt" ]  || tzvt_tmux_win_current_fmt='#F#I:#W'
[ -n "$tzvt_tmux_win_other_fmt" ]    || tzvt_tmux_win_other_fmt='#F#I:#W'

## ZSH
[ -n "$tzvt_zsh_title_fmt" ]  || tzvt_zsh_title_fmt='${cmd}:${pth}'

## Vim
[ -n "$tzvt_vim_title_prefix" ] || tzvt_vim_title_prefix="v:"
# Include PATH in vim title:
#  true=path from current location
#  long=entire path, shortened by ZSH named dirs if run from ZSH
#  zsh=try to use ZSH named dirs if ZSH installed, fallback to no path
#  false=do not include a PATH, the default (it's cleaner)
[ -n "$tzvt_vim_include_path" ] || tzvt_vim_include_path=false
