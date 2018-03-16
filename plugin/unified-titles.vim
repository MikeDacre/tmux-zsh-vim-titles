"""""""""""""""""""""""""
"  Set Title by Buffer  "
"""""""""""""""""""""""""

" Start fresh
set notitle

" Get Variables
let vim_title_prefix = system('[ -n "$vim_title_prefix" ] || vim_title_prefix="v:"; echo -n "${vim_title_prefix}" | tr -d "[:space:]"')
let hastmux = system('[ -z "$TMUX" ] && echo -n false || echo -n true | tr -d "[:space:]"')
let override = system('[ -z "$vim_force_tmux_title_change" ] && echo -n false || echo -n true | tr -d "[:space:]"')
let window_update = system('[ -z "$tmux_set_window_status" ] && echo -n false || echo -n true | tr -d "[:space:]"')
if window_update == 'true'
  let win_orig_status = system('[ -n "$tmux_win_current_fmt" ] || tmux_win_current_fmt="#I:#W#F" ; echo -n $tmux_win_current_fmt')
  " We use the terminal title in both the terminal and status line in
  " vim only, so substitute window name (#W) for terminal title (#T)
  let win_vim_status  = substitute(win_orig_status, '#W', '#T', 'g')
endif

" Set tmux control chars
if hastmux == 'true'
  if &term == "screen" || &term == "screen-256color"
    set t_ts=]0;
    set t_fs=
  elseif &term == 'nvim'
    set t_ts=k
    set t_fs=
  endif
endif

" Functions
function! SetTmuxTerminalTitle(titleString)
  let cmd2 = 'silent !echo -n -e "\033]0;' . a:titleString . '\007"'
  let cmd3 = 'silent !echo -n -e "\033k' . a:titleString . '\007"'
  execute cmd2
  execute cmd3
  redraw!
endfunction

function! SetTmuxWindowTitle(titleString, titleFormat)
  " While on the current window, we will use the terminal title
  call system('tmux set window-status-current-format ' . shellescape(a:titleFormat))
  " While on other windows we will still use the name
  call system("tmux rename-window " . a:titleString)
endfunction

function! GetModStr()
  if &modified
    return '+'
  endif
  return ''
endfunction

" Handle special characters
let my_asciictrl = nr2char(127)
let my_unisubst = "␡"
for i in range(1, 31)
  let my_asciictrl .= nr2char(i)
  let my_unisubst  .= nr2char(0x2400 + i, 1)
endfor

" Change title on everything
if window_update == 'true'
  let simpleTitle = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
  let modStr = GetModStr()
  if hastmux == 'true' || &term == "screen" || &term == "screen-256color"
    call SetTmuxWindowTitle(simpleTitle, win_vim_status)
  endif
endif
set title titlestring=%{vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)

" Use autocommands if the user wants to also update the tmux status window name
" or if the simple titlestring setting does not work.
if window_update == 'true' || override == 'true'
  augroup termTitle
    " Clear prior commands in termTitle
    au!
    " Only do anything if we are in tmux
    if hastmux == 'true' || &term == "screen" || &term == "screen-256color"
      autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FocusLost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * let modStr = GetModStr()
      autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FocusLost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * let simpleTitle = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst) . modStr
      " Set window titles
      if window_update == 'true'
        autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FocusLost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * call SetTmuxWindowTitle(simpleTitle, win_vim_status)
        autocmd VimLeave * call SetTmuxWindowTitle("", win_orig_status)
      endif
      " Set title using terminal commands
      if override == 'true'
        autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * call SetTmuxTerminalTitle(simpleTitle)
      endif
      " Clear title on leaving vim
      autocmd VimLeave * set t_ts=k\
    endif
  augroup END
endif
