" Use vim-plug for plugin management
call plug#begin('~/.vim/plugged')

" Plugins
Plug 'elixir-editors/vim-elixir'      " Elixir language support
Plug 'dense-analysis/ale'             " ALE for linting and formatting
Plug 'scrooloose/nerdtree'            " File explorer
Plug 'ryanoasis/vim-devicons'         " NERDTree icons
Plug 'psliwka/vim-smoothie'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()
