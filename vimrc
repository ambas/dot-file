" Set color scheme to molokai
colorscheme molokai

" Enable 256-color support for better compatibility
set t_Co=256

" Background preference (dark is recommended for molokai)
set background=dark

" -----------------
" Encoding and Syntax
" -----------------
" Set encoding to UTF-8
set encoding=UTF-8

" Enable syntax highlighting
syntax enable

" -----------------
" Plugin Manager Initialization
" -----------------
" Use vim-plug for plugin management
call plug#begin('~/.vim/plugged')

" Plugins
Plug 'elixir-editors/vim-elixir'      " Elixir language support
Plug 'dense-analysis/ale'            " ALE for linting and formatting
Plug 'scrooloose/nerdtree'           " File explorer
Plug 'ryanoasis/vim-devicons'        " NERDTree icons

call plug#end()

" -----------------
" NERDTree Settings
" -----------------
" Map Ctrl+n to toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

" Show hidden files in NERDTree
let g:NERDTreeShowHidden = 1

" Auto close NERDTree when it's the last window
let g:NERDTreeQuitOnOpen = 1

" Enable relative line numbers for NERDTree
augroup NERDTreeSettings
  autocmd!
  autocmd FileType nerdtree setlocal relativenumber
  autocmd BufEnter * if &filetype == 'nerdtree' | setlocal relativenumber | endif
augroup END

" Enable NERDTree icons
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1
let g:webdevicons_conceal_nerdtree_brackets = 1

" -----------------
" ALE Settings (Asynchronous Lint Engine)
" -----------------
" Configure linters and fixers for Elixir
let g:ale_linters = {
\   'elixir': ['credo']
\}
let g:ale_fixers = {
\   'elixir': ['mix_format']
\}

" Enable fixing on save
let g:ale_fix_on_save = 1

" Enable ALE linting in the background
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1

" -----------------
" Global Editor Settings
" -----------------
" Enable relative line numbers
set relativenumber

" Enable clipboard for system copy-paste
set clipboard=unnamed

" Enable line numbers in all buffers
set number

" -----------------
" Search Settings
" -----------------
" Improve search behavior
set ignorecase          " Ignore case when searching
set smartcase           " Case-sensitive if uppercase letters are used
set incsearch           " Incremental search

" -----------------
" File Type Specific Settings
" -----------------
" Set up auto-indentation for Elixir
filetype plugin indent on

" -----------------
" Leader Key and Custom Mappings
" -----------------
" Set leader key to space
let mapleader = " "

set timeoutlen=100

" Quick save and run
nnoremap <leader>w :w <CR>
nnoremap <leader>r :w \| @:<CR>

