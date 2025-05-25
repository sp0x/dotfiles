filetype on
filetype plugin on

"pathogen plugin manager
execute pathogen#infect()

"----------Settings-----------

syntax on      "Syntax highlight on
filetype plugin indent on

set backspace=indent,eol,start   "Make backspace work like in mac
let mapleader = ','              "Change leader from 
set number       "Sets linenumbers
set linespace=15     "Sets line spacing but only in gui

set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

"---------Colors------------

hi vertsplit ctermfg=256 ctermbg=256  "change color of separator
hi StatusLine ctermfg=256 ctermbg=140 "change color of statusline

"---------Statusline--------
set statusline=%=\ %f\ %m
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set noshowmode

"----------Search-----------  

set hlsearch       "Highlight search term 
set incsearch      "Incremental highlight term

"----------Mappings-----------

"Open .vimrc by ,ev
nmap <Leader>ev :tabedit $MYVIMRC<cr>
"Deselect search highlight by , <space>
nmap <Leader><space> :nohlsearch<cr>
"Toggle NERDTree by ,n
nmap <Leader>n :NERDTreeToggle<cr>
nnoremap <C-n> :NERDTree<CR>
"----------Auto-commmands----

"Automatically source the .vimrc file on save.

augroup autosourcing
  autocmd!
  autocmd BufWritePost .vimrc source %
augroup END

"Opens NERDTree if no file specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif


" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

