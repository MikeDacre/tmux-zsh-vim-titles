#!/usr/bin/env zsh
# Set the ZSH component of the title string
# This component is *heavily* inspired by https://github.com/jreese/zsh-titles

CURRENT_DIR="$(dirname $0:A)"

[ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null && in_tmux=true || in_tmux=false

# Get the user config, if it exists (defaults to ~/.tzvt_config)
. "$CURRENT_DIR/scripts/get_tzvt_config.sh"

# Get default starting strings, no existing variables overwritten.
# shellcheck source=defaults.sh
. "$CURRENT_DIR/defaults.sh"

# Check if we want to update tmux
if $in_tmux && [[ $tzvt_zsh_update_tmux == true ]] && [[ $(tmux show-option -gqv tzvt_initialized) == true ]]; then
    # Check if plugin installed
    t_plug=true
else
    t_plug=false
fi

# Run the tmux title setting plugin on shell start
TITLE_PRE=""
if ! $in_tmux; then
    if [ -n "$SSH_CONNECTION" ] || [[ $(command ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        if [ -n "$tzvt_host_dict" ]; then
            TITLE_PRE="$($CURRENT_DIR/scripts/get_hoststring.py --host-only | tr -d "[:space:]"):"
        elif [ -n "$HOSTSHORT" ]; then
            TITLE_PRE="${HOSTSHORT}:"
        elif [ -n "$HOSTNAME" ]; then
            TITLE_PRE="${HOSTNAME}:"
        else
            TITLE_PRE="${HOST}:"
        fi
    fi
fi

# Set titles
function update_title() {
    local cmd
    local pth
    # escape '%' in $1, make nonprintables visible
    cmd=${(V)1//\%/\%\%}
    # remove newlines
    cmd=${cmd//$'\n'/}
    pth="%${tzvt_pth_width}<...<%~"
    short_pth="%${tzvt_win_pth_width}<...<%~"

    # Set core titles
    if [ -n "$cmd" ]; then
        TITLE=$(eval echo "${tzvt_zsh_title_fmt}")
        SHORT_TITLE=$(eval echo "${tzvt_zsh_title_fmt/$'pth'/short_pth}")
    else
        TITLE=${pth}
        SHORT_TITLE=${short_pth}
    fi

    # Add host to title if necessary
    if [ -n "$TITLE_PRE" ] && [[ ! "$TITLE" =~ "$TITLE_PRE" ]]; then
        TITLE="${TITLE_PRE}${TITLE}"
    fi

    ## Terminal title (work even if ssh from tmux)

    # Emulator dependent, results in double title set with knosole
    if [ -n "$KONSOLE_DBUS_SERVICE" ]; then
        print -Pn "\033]30;${(%)TITLE}\007"
    fi

    # Term dependent
    if $in_tmux; then
        # print -Pn "\ek${(%)TITLE}\e\\"  # Sets window name
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ screen* ]] || [[ "$TERM" =~ xterm* ]]; then
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ ^rxvt-unicode.* ]]; then
        printf '\33]2;%s\007' ${(%)TITLE}
    fi

    # Tmux Specific Stuff
    if $in_tmux; then
        # Reset tmux portion of the title if plugin is installed
        # Run as source to preserve current environment
        if $t_plug; then
            # shellcheck source=scripts/set_tmux_title.sh
            . $CURRENT_DIR/scripts/set_tmux_title.sh
        fi

        # Tmux Window Title
        if [ -n "$tzvt_set_tmux_window_status" ]; then
            # Only set the current window format globally once, as it is overriden elsewhere
            tmux set-window-option window-status-current-format "${tzvt_tmux_win_current_fmt}"

            # Window title is short path
            # print -Pn "\ek${(%)SHORT_TITLE}\e\\"  # Sets window name
            tmux rename-window "${(%)SHORT_TITLE}"
        fi
    fi
}

# Called just before a command is executed
# Title component will the command and the path
function _zsh_title__preexec() {
    local -a cmd

    # Re-parse the command line
    cmd=(${(z)@})

    # Construct a command that will output the desired job number.
    case $cmd[1] in
        fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
        %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
    esac

    cmd="${cmd[1]}"

    # Escape '\'
    cmd="${cmd//\\/\\\\\\\\}"

	# Strip start and end whitespace
    cmd=$(echo "${cmd}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    update_title "${cmd}"
}

# Called just before the prompt is printed
# Title component will just be the path
function _zsh_title__precmd() {
    update_title
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_title__precmd
add-zsh-hook preexec _zsh_title__preexec

# Run once as the prompt is loading
update_title
