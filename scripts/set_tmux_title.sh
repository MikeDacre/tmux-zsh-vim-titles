#!/usr/bin/env bash
# Actually set the tmux terminal title, not the window title
# Inherits all variables from calling script, used by ZSH and
# tmux plugin

# Turn tmux titles on
tmux set -g set-titles on

# Is there a bell?
if [ -n "$1" ] && [[ "$1" == 'bell' ]]; then
    BELL_STR='!'
else
    BELL_STR=''
fi

# Update shell environment from variables
update_env_from_tmux() {
    eval "$(tmux show-environment -s | grep -v "^unset")"
}

main() {
    # Update the shell environment
    update_env_from_tmux
    # Detect if we are in an SSH session, use script to munge tzvt_tmux_title_format_ssh
	# if we are, else just use the simple title format
    # Note: SSH_TTY and SSH_CLIENT remain set by children of tmux if tmux started by an
    # SSH session, SSH_CONNECTION is reset though. The below test allows us to know if
    # we are currently accessing the terminal via SSH or not.
    if [ -n "$SSH_CONNECTION" ] || [[ $(command ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        tmux_string=$(tmux show-option -gqv @title-host-string)
    else
        tmux_string=$(tmux show-option -gqv @title-string)
    fi

	# Actually set the title
    tmux set -g set-titles-string "${BELL_STR}${tmux_string}"
}
main
