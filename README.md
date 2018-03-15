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

You will then need to source your tmux config (`tmux source ~/.tmux.conf`) and
install the plugin by pressing your prefix key combo (defaults to Ctrl+b)
followed by `I` (shift+i). You can update by running your prefix followed by
`U`.

### ZSH

The easiest way to install this plugin with ZSH is to use
[Antigen](https://github.com/zsh-users/antigen) by adding the following line to
the apprpriate spot in your `~/.zshrc` file:

```
antigen bundle MikeDacre/tmux-zsh-vim-titles
```

You will then need to reload your zsh configuration (e.g. by starting a new
shell or sourcing your `~/.zshrc` to install the plugin. You can update by
running `antigen upgrade`.

Alternatively, if you use
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), you can clone this into
your `oh-my-zsh` custom plugin directory:

1. `mkdir -p ${ZSH}/custom/plugins`
2. `cd ${ZSH}/custom/plugins`
3. `git clone https://github.com/MikeDacre/tmux-zsh-vim-titles.git`
4. Add `plugins+=(unified-titles)` to the right spot in your `~/.zshrc` and
   reloading zsh

To update you have to `cd` to the plugin directory and run `git pull`.

### Vim/NVIM

There are a great many plugin managers for vim/nvim right now, I personally use
[vim-plug](https://github.com/junegunn/vim-plug), to install with that manager,
just add the following line to the right spot in your `~/.vimrc` or
`~/nvim/init.vim`:

```
Plug 'MikeDacre/tmux-zsh-vim-titles'
```

You will then need to open a vim/nvim instance and run `PlugInstall` to install
the plugin. To update run `PlugUpdate`. The various other plugin managers work
similarly.

### Bash or another sh shell

If you also use a non-zsh shell, you can source the `bash-titles.plugin.sh` file
from your `~/.bashrc`. It doesn't do anywhere near as much as the ZSH version,
it simply sets the terminal title to the path, avoiding the otherwise long
titles that bash sometimes sets.

If anyone wants to port the zsh plugin to bash, that would be awesome. It should
be pretty easy, but I can't be bothered as I so rarely use bash.

## Configuration

The plugins will work right out of the box, but the formats can be configured
with a variety of shell variables. For example you could change the tmux prompt,
disable setting the window tab names, or change the delimiter from `:` to
something else.

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
those other plugins **will not display their titles**.

Additionally, if `$tmux_no_set_window_status` is set, the terminal title will
not be put in the status bar.

Note, after altering any of these settings, run `tmux source ~/.tmux.conf` to
implement the changes.

### ZSH title configuration

Without this plugin, the default ZSH title is just the hostname. This plugin
replaces this with the directory path or `command:path` if a command is running
in the terminal.

There is only one customization for this component:

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

Note, you can chose not to install the vim plugin, in which case either you will
end up with `vim:<path>` in the title, or another title produced internally by
vim, depending on your settings.
