set encoding=utf-8
set number
"set relativenumber

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
"set autowriteall

if has("autocmd")
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
endif

set autoindent
"set cindent
"set smartindent

"set ruler
set showcmd

"set cursorline

set incsearch
set hlsearch

if has("syntax")
  syntax on
endif

"set paste

if has('mac') || has('macunix') || has('osx') || has('osxdarwin')
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
endif

inoremap <c-g> <esc>
nnoremap \ q
nnoremap q <nop>
nnoremap Q <nop>
