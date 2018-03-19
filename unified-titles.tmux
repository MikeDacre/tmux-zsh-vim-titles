#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get default starting strings
# shellcheck source=scritps/set_tmux_title.sh
. $CURRENT_DIR/defaults.sh

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

main() {
    # Turn tmux titles on
    tmux set -g set-titles on

    if [[ "${USER}" == 'root' ]]; then
        tmux_start_str="${tmux_title_root}"
    else
        tmux_start_str="${tmux_title_start}"
    fi

    tmux_string="${tmux_start_str}${tmux_title_format}"
    tmux_host_string="${tmux_start_str}$("$CURRENT_DIR/scripts/get_hoststring.py" | tr -d '[:space:]')"

    # Set the title string in tmux
    tmux set -g @title-string "${tmux_string}"
    tmux set -g @title-host-string "${tmux_host_string}"

    # Actually set the titles
    # shellcheck source=scritps/set_tmux_title.sh
    . $CURRENT_DIR/scripts/set_tmux_title.sh

    # Preferentially get window status from tmux variable
    local tmux_internal_win_status
    tmux_internal_win_status=$(tmux show-option -gqv @tmux_set_window_status | tr -d "[:space:]")
    if [ -n "$tmux_internal_win_status" ]; then
        if [[ "$tmux_internal_win_status" == 'true' ]]; then
            tmux_set_window_status=true
        else
            tmux_set_window_status=false
        fi
    else
        if [ -n "$tmux_set_window_status" ] && "$tmux_set_window_status"; then
            tmux_set_window_status=true
            tmux set-option -gq @tmux_set_window_status true
        else
            tmux_set_window_status=false
            tmux set-option -gq @tmux_set_window_status false
        fi
    fi

    if $tmux_set_window_status; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set)
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
            tmux set-option -gq @win-status-set 'true'
        fi
        # Update the other format periodically
        tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
    fi
}
main
