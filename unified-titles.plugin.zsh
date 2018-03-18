#!/usr/bin/env zsh
# Set the ZSH component of the title string
# This component is *heavily* inspired by https://github.com/jreese/zsh-titles

CURRENT_DIR="$(dirname $0:A)"

# Get formats
[ -n "$zsh_title_fmt" ]  || zsh_title_fmt='${cmd}:${pth}'
[ -n "$pth_width" ]      || pth_width=60
[ -n "$win_pth_width" ]  || win_pth_width=25

if [ -n "$tmux_set_window_status" ] && [ -n "$TMUX" ]; then
    [ -n "$tmux_win_current_fmt" ] || tmux_win_current_fmt='#I:#W#F'
    [ -n "$tmux_win_other_fmt" ]   || tmux_win_other_fmt='#I:#W#F'
    tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
    tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
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
    if [ -n "$cmd" ]; then
        TITLE=$(eval echo "${zsh_title_fmt}")
        SHORT_TITLE=$(eval echo "${zsh_title_fmt/$'pth'/short_pth}")
    else
        TITLE=${pth}
        SHORT_TITLE=${short_pth}
    fi
    # If we are not on tmux, add hostname to TITLE string
    if [ ! -n "$TMUX" ]; then
        if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
            TITLE="$(${CURRENT_DIR}/scripts/get_hoststring.py --host-only):${TITLE}"
        fi
    fi
    # Terminal title
    if [[ -n "$TMUX" ]]; then
        print -Pn "\ek${(%)TITLE}\e\\"
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ screen* ]]; then
        print -Pn "\ek${(%)TITLE}\e\\"
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ xterm* ]]; then
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ ^rxvt-unicode.* ]]; then
        printf '\33]2;%s\007' ${(%)TITLE}
    fi
    # Tmux Specific Stuff
    if [ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null; then
        if [ ! -n "$tmux_set_window_status" ]; then
            export tmux_set_window_status=$(tmux show-option -gqv @tmux_set_window_status)
        fi
        # Tmux Window Title
        if [ -n "$tmux_set_window_status" ]; then
            # Only set the current window format globally once, as it is overriden elsewhere
            tmux set-window-option window-status-current-format "${tmux_win_current_fmt}"
            tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"

            # Window title is short path
            tmux rename-window "${(%)SHORT_TITLE}"
        fi

        # If ssh session has changed, rerun tmux plugin if installed
        if [ -f "$HOME/.tmux/plugins/tmux-zsh-vim-titles/unified-titles.tmux" ]; then
            if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ] || [[ $(ps -o comm= -p $PPID) =~ 'ssh' ]]; then
                if [[ ! $(tmux show-option -gqv @ssh-session-info) == "$SSH_CONNECTION" ]]; then
                    $HOME/.tmux/plugins/tmux-zsh-vim-titles/unified-titles.tmux
                fi
            fi
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

    cmd=${cmd[1]}

    # Escape '\'
    cmd=${cmd//\\/\\\\\\\\}

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
