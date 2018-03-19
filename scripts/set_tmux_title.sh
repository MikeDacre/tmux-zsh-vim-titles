#!/bin/bash
# Actually set the tmux terminal title, not the window title
# Inherits all variables from calling script, used by ZSH and
# tmux plugin

# Turn tmux titles on
tmux set -g set-titles on

main() {
    # Detect if we are in an SSH session, use script to munge tmux_title_format_ssh
	# if we are, else just use the simple title format
    # Note: SSH_TTY and SSH_CLIENT remain set by children of tmux if tmux started by an
    # SSH session, SSH_CONNECTION is reset though. The below test allows us to know if
    # we are currently accessing the terminal via SSH or not.
    if [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        tmux_string=$(tmux show-option -gqv @title-host-string)
    else
        tmux_string=$(tmux show-option -gqv @title-string)
    fi

	# Actually set the title
    tmux set -g set-titles-string "${tmux_string}"
}
main
