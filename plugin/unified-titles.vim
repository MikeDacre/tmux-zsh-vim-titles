" Set Title
let vim_title_prefix = system('[ -n "$vim_title_prefix" ] || vim_title_prefix="v:"; echo "${vim_title_prefix}"')
autocmd BufEnter * let &titlestring = vim_title_prefix . expand("%:t")
set title
