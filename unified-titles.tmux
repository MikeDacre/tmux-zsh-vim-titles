#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get default starting strings
# shellcheck source=defaults.sh
. "$CURRENT_DIR/defaults.sh"

# Attempt to get all applicable profiles as tmux runs this code
# with no environment
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile" 2>/dev/null >/dev/null
fi

TMUX_CONF=$(tmux show-option -gqv @tmux_conf | tr -d "[:space:]")
if [ -z "$TMUX_CONF" ]; then
    TMUX_CONF="$HOME/.tmux/profile.sh"
    tmux set -gq @tmux_conf "$TMUX_CONF"
fi
if [ -f "$TMUX_CONF" ]; then
    source "$TMUX_CONF" 2>/dev/null >/dev/null
fi

# Add variables to the tmux environment
variables="tmux_set_window_status"
variables+=" vim_force_tmux_title_change"
variables+=" tmux_title_start"
variables+=" tmux_title_root"
variables+=" tmux_title_format"
variables+=" tmux_title_format_ssh"
variables+=" tmux_win_current_fmt"
variables+=" tmux_win_other_fmt"
tmux set -g update-environment "${variables}"

main() {
    # Turn tmux titles on
    tmux set -g set-titles on

    if [[ "${USER}" == 'root' ]]; then
        tmux_start_str="${tmux_title_root}"
    else
        tmux_start_str="${tmux_title_start}"
    fi

    tmux_string="#{window_bell_flag,!,}${tmux_start_str}${tmux_title_format}"
    tmux_host_string="#{window_bell_flag,!,}${tmux_start_str}$("$CURRENT_DIR/scripts/get_hoststring.py" | tr -d '[:space:]')"

    # Set the title string in tmux
    tmux set -g @title-string "${tmux_string}"
    tmux set -g @title-host-string "${tmux_host_string}"

    # Actually set the titles, also run by ZSH
    # shellcheck source=scripts/set_tmux_title.sh
    . "$CURRENT_DIR/scripts/set_tmux_title.sh"

    # Update window name if requested
    if $tmux_set_window_status; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set)
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
            tmux set-window-option -g automatic-rename-format "${tmux_win_other_fmt}"
            tmux set-window-option -g automatic-rename on
            tmux set-option -gq @win-status-set 'true'
        fi
        # Update the other format periodically
        tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
    fi
}
main

# Update string on attach and detatch
tmux set-hook -g after-client-attached "run \"$CURRENT_DIR/unified-titles.tmux\""
# tmux set-hook -g alert-bell "run \"$CURRENT_DIR/scripts/set_tmux_title.sh bell\""
tmux set-hook -g after-client-detached "run \"echo -ne \\\"\e]0;$HOSTNAME\a\\\"\""
