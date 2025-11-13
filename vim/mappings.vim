" Set leader key to space
let mapleader = " "
let localmapleader = "\\" " Optional: set a different leader for local buffer mappings

" Timeout for mapped sequences (milliseconds)
" Affects how long Vim waits for the next key in a mapping.
" 1000ms is default. 100ms is very short, adjust if you have slow multi-key mappings.
set timeoutlen=100
" set ttimeoutlen=10 " Timeout for key codes (e.g. escape sequences)

" Quick save and run
" nnoremap: non-recursive mapping in Normal mode
nnoremap <leader>w :w<CR>
" This mapping is a bit unusual. '@:' repeats the last command-line command.
" So, leader+r will save and then repeat whatever your last :command was.
" If you intend to, for example, run the current file, you'd need something more specific.
" For Elixir, it might be: nnoremap <leader>r :w \| !mix run %<CR> (example)
nnoremap <leader>r :w \| @:<CR>

" --- fzf.vim mappings ---
" Search files in the current directory (respects .gitignore)
nnoremap <leader>f :Files<CR>

" In insert mode, create a new line above and continue inserting (Escape + Shift+O)
inoremap <C-o> <Esc>O
