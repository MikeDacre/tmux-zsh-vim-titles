#!/usr/bin/env zsh
# Set the ZSH component of the title string
# This component is *heavily* inspired by https://github.com/jreese/zsh-titles

CURRENT_DIR="$(dirname $0:A)"

# Get default starting strings
# shellcheck source=defaults.sh
. $CURRENT_DIR/defaults.sh

# Source tmux profile if available
TMUX_CONF=$(tmux show-option -gqv @tmux_conf | tr -d "[:space:]")
[ -n "$TMUX_CONF" ] || TMUX_CONF="$HOME/.tmux/profile.sh"
if [ -f "$TMUX_CONF" ]; then
    source "$TMUX_CONF" 2>/dev/null >/dev/null
fi

# Run the tmux title setting plugin on shell start
if [ -n "$TMUX" ]; then
    if [ -x "$HOME/.tmux/plugins/tmux-zsh-vim-titles/unified-titles.tmux" ]; then
        $HOME/.tmux/plugins/tmux-zsh-vim-titles/unified-titles.tmux
    fi
else
    if [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
        TITLE_PRE="$($CURRENT_DIR/scripts/get_hoststring.py --host-only)"
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
    pth="%${pth_width}<...<%~"
    short_pth="%${win_pth_width}<...<%~"

    # Set core titles
    if [ -n "$cmd" ]; then
        TITLE=$(eval echo "${zsh_title_fmt}")
        SHORT_TITLE=$(eval echo "${zsh_title_fmt/$'pth'/short_pth}")
    else
        TITLE=${pth}
        SHORT_TITLE=${short_pth}
    fi
    TITLE="${TITLE_PRE}:${TITLE}"

    # Terminal title (work even if ssh from tmux)
    if [ -n "$TMUX" ] || [[ "$TERM" =~ screen* ]]; then
        # print -Pn "\ek${(%)TITLE}\e\\"  # Sets window name
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ xterm* ]]; then
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ ^rxvt-unicode.* ]]; then
        printf '\33]2;%s\007' ${(%)TITLE}
    fi

    # Tmux Specific Stuff
    if $in_tmux; then
        # Reset tmux portion of the title if plugin is installed
        # Run as source to preserve current environment
        if [ -f "$HOME/.tmux/plugins/tmux-zsh-vim-titles/unified-titles.tmux" ]; then
            # shellcheck source=scripts/set_tmux_title.sh
            . $CURRENT_DIR/scripts/set_tmux_title.sh
        fi

        # Tmux Window Title
        if [ -n "$tmux_set_window_status" ]; then
            # Only set the current window format globally once, as it is overriden elsewhere
            tmux set-window-option window-status-current-format "${tmux_win_current_fmt}"

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
