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

function! SetTmuxWindowTitle(titleString)
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
let simpleTitle = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst)
let modStr = GetModStr()
if window_update == 'true' && hastmux == 'true'
  call system("tmux rename-window " . simpleTitle)
endif
set title titlestring=%{vim_title_prefix}%(%{expand(\"%:t\")}%)%(\ %M%)

" Primary autocommands
if window_update == 'true' || override == 'true'
  augroup termTitle
    au!
    autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * let modStr = GetModStr()
    autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * let simpleTitle = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst) . modStr
    " autocmd BufAdd,BufLeave,TabEnter,WinEnter,BufReadPost,FileReadPost,BufNewFile,BufEnter,InsertEnter,BufWritePost,FileWritePost * let simpleTitle = vim_title_prefix . tr(expand("%:t"), my_asciictrl, my_unisubst) . modStr
    if hastmux == 'true' || &term == "screen" || &term == "screen-256color"
      " Set window titles
      if window_update == 'true'
        autocmd BufAdd,BufEnter,BufLeave,BufWritePost,FileChangedShellPost,FileWritePost,InsertEnter,TabEnter,WinEnter * call SetTmuxWindowTitle(simpleTitle)
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
