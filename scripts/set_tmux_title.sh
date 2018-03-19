#!/bin/bash
# Actually set the tmux terminal title, not the window title
# Inherits all variables from calling script, used by ZSH and
# tmux plugin

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$( cd "$( dirname "$CURRENT_DIR" )" && pwd )"

# Turn tmux titles on
tmux set -g set-titles on

main() {
    # Get default starting strings
    # shellcheck source=../defaults.sh
    . $PARENT_DIR/defaults.sh

    local tmux_start_str
    local tmux_string

    if [[ "${USER}" == 'root' ]]; then
        tmux_start_str="${tmux_title_root}"
    else
        tmux_start_str="${tmux_title_start}"
    fi
    local host_script
    if [ -x "$CURRENT_DIR/get_hoststring.py" ]; then
        host_script="$CURRENT_DIR/get_hoststring.py"
    elif [ -x "$CURRENT_DIR/scripts/get_hoststring.py" ]; then
        host_script="$CURRENT_DIR/scripts/get_hoststring.py"
    else
        echo "Cannot find get_hoststring.py!"
        exit 1
    fi

    # Detect if we are in an SSH session, use script to munge tmux_title_format_ssh
	# if we are, else just use the simple title format
    # Note: SSH_TTY and SSH_CLIENT remain set by children of tmux if tmux started by an
    # SSH session, SSH_CONNECTION is reset though. The below test allows us to know if
    # we are currently accessing the terminal via SSH or not.
    if [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        tmux_string="${tmux_start_str}$(${host_script} | tr -d '[:space:]')"
        tmux set-option -gq @in-ssh true
    else
        tmux_string="${tmux_start_str}${tmux_title_format}"
        tmux set-option -gq @in-ssh false
    fi

	# Actually set the title
    tmux set -g set-titles-string "${tmux_string}"
}
main
