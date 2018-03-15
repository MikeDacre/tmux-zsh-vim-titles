# Unified Tmux-ZSH-Vim Terminal Titles

Creates intelligent terminal titles in tmux, zsh, and vim, that work together
to give information about session, ssh host, path, and currently edited vim
buffer. Each part is modular and must be installed separately.

## Installation

### Tmux

Install with [tpm](https://github.com/tmux-plugins/tpm) by adding the following
line to your `.tmux.conf`:

```
set -g @plugin 'MikeDacre/tmux-zsh-vim-titles'
```

### ZSH

The easiest way to install this plugin with ZSH is to use
[Antigen](https://github.com/zsh-users/antigen) by adding the following line to
the apprpriate spot in your `~/.zshrc` file:

```
antigen bundle MikeDacre/tmux-zsh-vim-titles
```

Alternatively, if you use
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), you can clone this into
your `oh-my-zsh` custom plugin directory:

1. `mkdir -p ${ZSH}/custom/plugins`
2. `cd ${ZSH}/custom/plugins`
3. `git clone https://github.com/MikeDacre/tmux-zsh-vim-titles.git`
4. Add `plugins+=(unified-titles)` to the right spot in your `~/.zshrc`

### Vim/NVIM

There are a great many plugin managers for vim/nvim right now, I personally use
[vim-plug](https://github.com/junegunn/vim-plug), to install with that manager,
just add the following line to the right spot in your `~/.vimrc` or
`~/nvim/init.vim`:

```
Plug 'MikeDacre/tmux-zsh-vim-titles'
```

## Configuration

The plugins will work right out of the box, but the formats can be configured
with a variety of shell variables. These are:

### Tmux title configuration

Tmux is the first part of the title, the default title is `t:<session>:` on a
local machine, or `t:<session>:<hostname>` on a remote machine. The `t:` is
replaced with `rt` if you are root.

These variations are controlled by the following optional variables:

- `tmux_title_start='t:'`
- `tmux_title_root='rt:'`
- `tmux_title_format='#S:#T'`
- `tmux_title_format_ssh='#h:#S:#T'`
- `tmux_win_current_fmt='#I:#T'`
- `tmux_win_other_fmt='#I:#T'`

The format strings that start with a `#` are tmux specific and can be found in
the tmux man page. `#S` is the session name, `#I` is the window number, `#h` is
the short hostname.

`#T` is the terminal title and is set by the zsh and vim plugins, without it
those other plugins will not display their titles

Additionally, if `$tmux_no_set_window_status` is set, the terminal title will
not be put in the status bar.

Note, after altering any of these settings, run `tmux source ~/.tmux.conf` to
implement the changes.

### ZSH title configuration

Without this plugin, the default ZSH title is just the hostname. This plugin
replaces this with the directory path or `command:path` if a command is running
in the terminal.

There is only one custoization for this component:

- `zsh_title_fmt='${cmd}:${path}'`

Not the single quotes, this is very important to prevent the variable from being
expanded to early, you must not use `"{cmd}:${path}"`, that will result in the
string `:` being passed to the plugin.

### Vim/NVIM title configuration

For all other commands, the title will be `command:path`, but for vim or NVIM,
instead we use `v:<buffer>`, e.g. `v:README.md` or `v:[BUFEXPLORER]`. This title
is updated immediately on any buffer change, which makes it very useful.

The only thing that can be changed here is the prefix, currently set as `v:` to
keep it out of the way:

- `vim_title_prefix="v:"`
