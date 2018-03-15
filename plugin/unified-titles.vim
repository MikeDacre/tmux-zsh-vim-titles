"""""""""""""""""""""""""
"  Set Title by Buffer  "
"""""""""""""""""""""""""

" Start fresh
set notitle

" Get Variables
let vim_title_prefix = system('[ -n "$vim_title_prefix" ] || vim_title_prefix="v:"; echo -n "${vim_title_prefix}" | tr -d "[:space:]"')
let hastmux = system('[ -z "$TMUX" ] && echo -n false || echo -n true | tr -d "[:space:]"')

" Set tmux control chars
if hastmux == 'true' || &term == "screen" || &term == "screen-256color"
  set t_ts=k
  set t_fs=\
endif

" Handle special characters
let my_asciictrl = nr2char(127)
let my_unisubst = "␡"
for i in range(1, 31)
  let my_asciictrl .= nr2char(i)
  let my_unisubst  .= nr2char(0x2400 + i, 1)
endfor

" Change title on everything
let &titlestring = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
if has('nvim')
  set title titlestring=%{vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)
else
  set title
endif
augroup termTitle
  au!
  autocmd TabEnter,WinEnter,BufReadPost,FileReadPost,BufNewFile,BufEnter * let &titlestring = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
  if has('nvim')
    autocmd TabEnter,WinEnter,BufReadPost,FileReadPost,BufNewFile,BufEnter * set title titlestring=%{vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)
  else
    autocmd TabEnter,WinEnter,BufReadPost,FileReadPost,BufNewFile,BufEnter * set title
  endif
  autocmd VimLeave * set t_ts=k\
augroup END

" Apparently this doesn't work in some vim/nvim versions on tmux
" Set title using terminal commands
function! SetTerminalTitle(titleString)
      let cmd2 = 'silent !echo -n -e "\033]0;' . a:titleString . '\007"'
      let cmd3 = 'silent !echo -n -e "\033k' . a:titleString . '\007"'
      execute cmd3
      execute cmd2
      redraw!
      call system("tmux rename-window " . a:titleString)
endfunction

" Set tmux window name manually just in case titles fail
if hastmux == 'true' || &term == "screen" || &term == "screen-256color"
  let tmux_win_fmt = system('[ -n "$tmux_win_current_fmt" ] || tmux_win_current_fmt="#I:#T"; echo "${tmux_win_current_fmt}"')
  augroup termTitleHack
    au!
    autocmd BufEnter * call SetTerminalTitle(&titlestring)
    autocmd VimLeave * call system("tmux rename-window " . tmux_win_fmt)
  augroup END
endif
