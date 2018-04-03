#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Attempt to get all applicable profiles as tmux runs this code
# with no environment
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile" 2>/dev/null >/dev/null
fi

# Get the user config, if it exists (defaults to ~/.tzvt_config)
. "$CURRENT_DIR/scripts/get_tzvt_config.sh"

# Get default starting strings, no set variables overwritten
# shellcheck source=defaults.sh
. "$CURRENT_DIR/defaults.sh"

_init_tzvq() {
    # Add variables to the tmux environment
    declare -a all_vars
    all_vars=("DISPLAY" "SSH_CONNECTION" "tzvt_set_tmux_window_status" "tzvt_vim_force_tmux_title_change" \
            "tzvt_tmux_title_start" "tzvt_tmux_title_root" "tzvt_tmux_title_format" "tzvt_tmux_title_format_ssh" \
            "tzvt_tmux_win_current_fmt" "tzvt_tmux_win_other_fmt")
    # Get existing tmux update-environment variables
    variables="$(tmux show-option -g update-environment | sed 's/.*] "\([^"]\+\)"/\1/' | xargs echo -n)"
    # Add ours only if they do not already exist
    for var in "${all_vars[@]}"; do
        if [[ ! "$variables" =~ $var ]]; then
            variables+=" $var"
        fi
    done
    # Set them now, they will be updated in the shell by sourcing
    # scripts/set_tmux_title.sh
    tmux set -g update-environment "${variables}"

    # Make a note that we have run
    tmux set -gq @tzvt_initialized true
}

main() {
    if [[ ! $(tmux show-option -gqv tzvt_initialized) == true ]]; then
        _init_tzvq
    fi

    # Turn tmux titles on
    tmux set -g set-titles on

    if [[ "${USER}" == 'root' ]]; then
        tmux_start_str="${tzvt_tmux_title_root}"
    else
        tmux_start_str="${tzvt_tmux_title_start}"
    fi

    local host_string
    local host_sep='#h'
    # Munge the host string just once, but only if necessary
    if [[ $tzvt_tmux_title_format_ssh =~ $host_sep ]]; then
        if [ -n "$tzvt_host_dict" ]; then
            echo "$tzvt_host_dict"
            host_string="$($CURRENT_DIR/scripts/get_hoststring.py | tr -d "[:space:]"):"
        elif [ -n "$HOSTSHORT" ]; then
            host_string="${tzvt_tmux_title_format_ssh/$host_sep/$HOSTSHORT}"
        elif [ -n "$HOSTNAME" ]; then
            host_string="${tzvt_tmux_title_format_ssh/$host_sep/$HOSTNAME}"
        else
            host_string="${tzvt_tmux_title_format_ssh/$host_sep/$HOST}"
        fi
    else
        host_string="$tzvt_tmux_title_format_ssh"
    fi

    # We use tmux_string if we are local, and tmux_host_string if we are on ssh
    tmux_string="#{window_bell_flag,!,}${tmux_start_str}${tzvt_tmux_title_format}"
    tmux_host_string="#{window_bell_flag,!,}${tmux_start_str}${host_string}"

    # Set the title string in tmux
    tmux set -g @title-string "${tmux_string}"
    tmux set -g @title-host-string "${tmux_host_string}"

    # Actually set the titles, also run by ZSH
    # shellcheck source=scripts/set_tmux_title.sh
    . "$CURRENT_DIR/scripts/set_tmux_title.sh"

    # Update window name if requested
    if $tzvt_set_tmux_window_status; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set)
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tzvt_tmux_win_current_fmt}"
            tmux set-window-option -g automatic-rename-format "${tzvt_tmux_win_other_fmt}"
            tmux set-window-option -g automatic-rename on
            tmux set-option -gq @win-status-set 'true'
        fi
        # Update the other format periodically
        tmux set-window-option -g window-status-format "${tzvt_tmux_win_other_fmt}"
    fi
}
main

# Update string on attach and detatch
tmux set-hook -g after-client-attached "run \"$CURRENT_DIR/unified-titles.tmux\""
tmux set-hook -g alert-bell "run \"$CURRENT_DIR/scripts/set_tmux_title.sh bell\""
tmux set-hook -g after-client-detached "run \"echo -ne \\\"\e]0;$HOSTNAME\a\\\"\""
