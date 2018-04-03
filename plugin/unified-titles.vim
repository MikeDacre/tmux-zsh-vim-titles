"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Set Title by Buffer                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""
"  Check and Get Environment  "
"""""""""""""""""""""""""""""""

" Get path to self
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Source shell profiles
call system('cd $(dirname ' . s:path . '); source scripts/get_tzvt_config.sh')
call system('cd $(dirname ' . s:path . '); source defaults.sh')

" Get Variables
if !exists("g:tzvt_vim_title_prefix")
  let g:tzvt_vim_title_prefix = system('[ -n "$tzvt_vim_title_prefix" ] || tzvt_vim_title_prefix="v:"; echo -n "${tzvt_vim_title_prefix}" | tr -d "[:space:]"')
endif
if !exists("g:tzvt_vim_force_tmux_title_change")
  let g:tzvt_vim_force_tmux_title_change = system('[ -n "$tzvt_vim_force_tmux_title_change" ] && $tmux_force_tmux_title_change && echo -n 1 || echo -n 0 | tr -d "[:space:]"')
endif
if !exists("g:tzvt_set_tmux_window_status")
  let g:tzvt_set_tmux_window_status = system('[ -n "$tzvt_set_tmux_window_status" ] && $tzvt_set_tmux_window_status && echo -n 1 || echo -n 0 | tr -d "[:space:]"')
endif
if !exists("g:tzvt_vim_include_path")
  let g:tzvt_vim_include_path = system('if [ -n "$tzvt_vim_include_path" ]; then if [[ $tzvt_vim_include_path == "long" ]]; then echo -n long; elif [[ $tzvt_vim_include_path == "zsh" ]]; then echo -n zsh; elif [[ $tzvt_vim_include_path == "true" ]]; then echo -n 1; else echo -n 0; fi; else echo -n 0; fi | tr -d "[:space:]"')
endif
if !exists("g:tzvt_vim_pth_width")
  let g:tzvt_vim_pth_width = system('[ -n "$tzvt_win_pth_width" ] || tzvt_win_pth_width=40; echo -n "$tzvt_win_pth_width" | tr -d "[:space:]"')
endif
if !exists("g:tzvt_vim_path_before")
  let g:tzvt_vim_pth_width = system('[ -n "$tzvt_vim_path_before" ] && [[ "$tzvt_vim_path_before" == true ]] && echo 1 || echo 0 | tr -d "[:space:]"')
endif
let s:zsh_bookmarks = system('[ -n "$ZSH_BOOKMARKS" ] || ZSH_BOOKMARKS="$HOME/.zshbookmarks"; echo -n "${ZSH_BOOKMARKS}" | tr -d "[:space:]"')
let s:has_tmux = system('[ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null && echo -n 1 || echo -n 0 | tr -d "[:space:]"')
let s:has_zsh = system('hash zsh 2>/dev/null && echo -n 1 || echo -n 0 | tr -d "[:space:]"')

" Get window format and update to terminal title if window status update
if g:tzvt_set_tmux_window_status
  let win_orig_status = system('[ -n "$tzvt_tmux_win_current_fmt" ] || tzvt_tmux_win_current_fmt="#I:#W#F" ; echo -n $tzvt_tmux_win_current_fmt')
  " We use the terminal title in both the terminal and status line in
  " vim only, so substitute window name (#W) for terminal title (#T)
  let win_vim_status  = substitute(win_orig_status, '#W', '#T', 'g')
endif

"""""""""""""""
"  Functions  "
"""""""""""""""

" Function to get named directory in zsh
function! ZSHDirs()
  let g:dir_path = system('zsh ' . s:path . '/get_zsh_named_dirs.zsh ' . expand("%:~:h") . ' ' . g:tzvt_vim_pth_width . ' ' . s:zsh_bookmarks)
endfunction

" Tmux Specific Functions
if g:tzvt_set_tmux_window_status || g:tzvt_vim_force_tmux_title_change

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
  let simpleTitle = g:tzvt_vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
endif


""""""""""""""""""""""""""""""
"  Set Basic Title Settings  "
""""""""""""""""""""""""""""""

" Start fresh
set notitle

" Set tmux control chars
if !s:has_tmux
  if &term == "screen" || &term == "screen-256color"
    set t_ts=]0;
    set t_fs=
  elseif &term == 'nvim'
    set t_ts=k
    set t_fs=
  endif
endif

"""""""""""""""""""
"  Set the Title  "
"""""""""""""""""""

" Decide which title to use
if g:tzvt_vim_include_path == '0' || g:tzvt_vim_include_path == '0'
  let s:title_type = 'simple'
elseif g:tzvt_vim_include_path == 'long'
  if $SHELL =~ 'zsh'
    let s:title_type = 'zsh'
  else
    let s:title_type = 'long'
  endif
elseif g:tzvt_vim_include_path == 'zsh'
  if $SHELL =~ 'zsh' || g:has_zsh == '1'
    let s:title_type = 'zsh'
  else
    let s:title_type = 'simple'
  endif
elseif g:tzvt_vim_include_path == 1 || g:tzvt_vim_include_path == '1'
  let s:title_type = 'short'
else
  let s:title_type = 'simple'
endif

" Actually set the terminal title
if s:title_type == 'simple'
  set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)
elseif s:title_type == 'zsh'
  call ZSHDirs()
  augroup zshPath
    au!
    autocmd BufEnter,BufNewFile,TabEnter,WinEnter * call ZSHDirs()
  augroup END
  if g:tzvt_vim_path_before
    set title titlestring=%{g:tzvt_vim_title_prefix}%{g:dir_path}:%(%{expand(\"%:t\")}%)%(\ %M%)
  else
    set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:t\")}%):%{g:dir_path}%(\ %M%)
  endif
elseif s:title_type == 'long'
  if g:tzvt_vim_path_before
    set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:~:p:t\")}%)%(\ %M%)
  else
    set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:t\")}%):%(%{expand(\"%:~:h\")}%)%(\ %M%)
  endif
elseif s:title_type == 'short'
  if g:tzvt_vim_path_before
    set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:~:.:p:t\")}%)%(\ %M%)
  else
    set title titlestring=%{g:tzvt_vim_title_prefix}%(%{expand(\"%:t\")}%):%(%{expand(\"%:~:.:h\")}%)%(\ %M%)
  endif
endif

" If requested set the initial window name
if g:tzvt_set_tmux_window_status
  if s:has_tmux || &term == "screen" || &term == "screen-256color"
    call SetTmuxWindowTitleFormat(simpleTitle, win_vim_status)
  endif
endif

""""""""""""""""""""""""""""""
"  Manage Tmux Window Names  "
""""""""""""""""""""""""""""""

" Use autocommands if the user wants to also update the tmux status window name
" or if the simple titlestring setting does not work.
if g:tzvt_set_tmux_window_status || g:tzvt_vim_force_tmux_title_change
  augroup termTitle
    " Clear prior commands in termTitle
    au!
    " Only do anything if we are in tmux
    if s:has_tmux || &term == "screen" || &term == "screen-256color"
      autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * let modStr = GetModStr()
      autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * let simpleTitle = g:tzvt_vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst) . modStr
      " Set window titles
      if g:tzvt_set_tmux_window_status
        autocmd BufEnter,BufLeave,BufWritePost,FileWritePost,InsertEnter,TabEnter,WinEnter * call SetTmuxWindowTitle(simpleTitle)
        autocmd VimLeave * call ResetTmuxWindowTitle(win_orig_status)
      endif
      " Set title using terminal commands
      if g:tzvt_vim_force_tmux_title_change
        autocmd BufEnter,BufWritePost,TabEnter,WinEnter * call SetTmuxTerminalTitle(simpleTitle)
      endif
      " Clear title on leaving vim
      autocmd VimLeave * set t_ts=k\
    endif
  augroup END
endif
