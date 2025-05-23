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

" Enable NERDTree icons (ensure vim-devicons is also configured if needed by itself)
" These settings are often specific to how vim-devicons integrates with NERDTree
let g:webdevicons_enable = 1 " General enable for vim-devicons
let g:webdevicons_enable_nerdtree = 1 " Specifically for NERDTree
let g:webdevicons_conceal_nerdtree_brackets = 1 " Optional: Hides brackets around icons
