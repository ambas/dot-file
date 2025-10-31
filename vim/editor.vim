" Highlight all matches when seraching or using *
set hlsearch
set incsearch
" Use 4 spaces for indent
" - tabstop: visual width of a tab character
" - shiftwidth: number of spaces used for each indentation level
" - expandtab: insert spaces when pressing <Tab>
set tabstop=4
set shiftwidth=4
set expandtab
" Enable relative line numbers globally
set relativenumber

" Enable absolute line numbers alongside relative ones
set number

" Enable clipboard for system copy-paste
" 'unnamed' uses the '*' register (system clipboard) for all yank, delete, put operations
" 'unnamedplus' uses the '+' register (primary X11 selection)
set clipboard=unnamed " Or unnamedplus, depending on your OS/preference

" Status line configuration
set laststatus=2 " Always show status line
" Customize status line: Full path, modified, readonly, help, preview, fileformat/type, line/col, percentage
set statusline=%F\ %m%r%h%w\ [%{&ff}/%Y]\ [%l,%v][%p%%]

" Improve search behavior
set ignorecase      " Ignore case when searching
set smartcase       " Case-sensitive if uppercase letters are used in search pattern
set incsearch       " Incremental search (show matches as you type)

" Enable filetype detection, plugins, and indentation
filetype plugin indent on

" Example: Set up auto-indentation for Elixir (though often handled by filetype plugins themselves)
" The line 'filetype plugin indent on' usually suffices for most languages
" including Elixir if vim-elixir is correctly installed.
" This specific setting might be redundant if vim-elixir handles it,
" but it doesn't hurt to be explicit if you face issues.
" autocmd FileType elixir setlocal expandtab shiftwidth=2 softtabstop=2
