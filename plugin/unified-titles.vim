"""""""""""""""""""""""""
"  Set Title by Buffer  "
"""""""""""""""""""""""""

" Start fresh
set notitle

" Get Variables
if !exists("g:vim_title_prefix")
  let g:vim_title_prefix = system('[ -n "$vim_title_prefix" ] || vim_title_prefix="v:"; echo -n "${vim_title_prefix}" | tr -d "[:space:]"')
endif
if !exists("g:vim_force_tmux_title_change")
  let g:vim_force_tmux_title_change = system('[ -n "$vim_force_tmux_title_change" ] && $tmux_force_tmux_title_change && echo -n 1 || echo -n 0 | tr -d "[:space:]"')
endif
if !exists("g:tmux_set_window_status")
  let g:tmux_set_window_status = system('[ -n "$tmux_set_window_status" ] && $tmux_set_window_status && echo -n 1 || echo -n 0 | tr -d "[:space:]"')
endif
if !exists("g:vim_include_path")
  let g:vim_include_path = system('if [ -n "$vim_include_path" ]; then if [[ $vim_include_path == "long" ]]; then echo -n long; elif [[ $vim_include_path == "true" ]]; then echo -n 1; else echo -n 0; fi; else echo -n 0; fi | tr -d "[:space:]"')
endif
let hastmux = system('[ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null && echo -n 1 || echo -n 0 | tr -d "[:space:]"')

" Get window format and update to terminal title if window status update
if g:tmux_set_window_status
  let win_orig_status = system('[ -n "$tmux_win_current_fmt" ] || tmux_win_current_fmt="#I:#W#F" ; echo -n $tmux_win_current_fmt')
  " We use the terminal title in both the terminal and status line in
  " vim only, so substitute window name (#W) for terminal title (#T)
  let win_vim_status  = substitute(win_orig_status, '#W', '#T', 'g')
endif

" Set tmux control chars
if !hastmux
  if &term == "screen" || &term == "screen-256color"
    set t_ts=]0;
    set t_fs=
  elseif &term == 'nvim'
    set t_ts=k
    set t_fs=
  endif
endif

" Run manual updates if requested
if g:tmux_set_window_status || g:vim_force_tmux_title_change

  " Override the terminal title if vim messes up
  function! SetTmuxTerminalTitle(titleString)
    let cmd2 = 'silent !echo -n -e "\033]0;' . a:titleString . '\007"'
    let cmd3 = 'silent !echo -n -e "\033k' . a:titleString . '\007"'
    execute cmd2
    execute cmd3
    redraw!
  endfunction

  " Set the window name and format
  function! SetTmuxWindowTitleFormat(titleString, titleFormat)
    " While on the current window, we will use the terminal title
    call system('tmux set window-status-current-format ' . shellescape(a:titleFormat))
    " While on other windows we will still use the name
    call SetTmuxWindowTitle(a:titleString)
  endfunction

  " Set the window name only
  function! SetTmuxWindowTitle(titleString)
    call system("tmux rename-window " . a:titleString)
  endfunction

  " Reset the window name to how it was before
  function! ResetTmuxWindowTitle(titleFormat)
    call SetTmuxWindowTitleFormat("", a:titleFormat)
    call system("tmux automatic-rename on")
  endfunction

  " Try to implement the '+' if file is modified.
  " Kinda works
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

  " Set the initial title. Initial title has no modStr.
  let simpleTitle = g:vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
endif

" If requested set the initial window name
if g:tmux_set_window_status
  if hastmux || &term == "screen" || &term == "screen-256color"
    call SetTmuxWindowTitleFormat(simpleTitle, win_vim_status)
  endif
endif

" Actually set the terminal title
if g:vim_include_path == 'long'
  set title titlestring=%{g:vim_title_prefix}%(%{expand(\"%:~:p:t\")}%)%(\ %M%)
elseif g:vim_include_path == '1'
  set title titlestring=%{g:vim_title_prefix}%(%{expand(\"%:~:.:p:t\")}%)%(\ %M%)
else
  set title titlestring=%{g:vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)
endif

" Use autocommands if the user wants to also update the tmux status window name
" or if the simple titlestring setting does not work.
if g:tmux_set_window_status || g:vim_force_tmux_title_change
  augroup termTitle
    " Clear prior commands in termTitle
    au!
    " Only do anything if we are in tmux
    if hastmux || &term == "screen" || &term == "screen-256color"
      autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * let modStr = GetModStr()
      autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * let simpleTitle = g:vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst) . modStr
      " Set window titles
      if g:tmux_set_window_status
        autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * call SetTmuxWindowTitle(simpleTitle)
        autocmd VimLeave * call ResetTmuxWindowTitle(win_orig_status)
      endif
      " Set title using terminal commands
      if g:vim_force_tmux_title_change
        autocmd BufEnter,BufWritePost,TabEnter,WinEnter * call SetTmuxTerminalTitle(simpleTitle)
      endif
      " Clear title on leaving vim
      autocmd VimLeave * set t_ts=k\
    endif
  augroup END
endif
