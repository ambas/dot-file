" Configure linters and fixers
let g:ale_linters = {
\   'elixir': ['credo'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tsserver'],
\   'javascriptreact': ['eslint'],
\   'typescriptreact': ['eslint', 'tsserver']
\}
let g:ale_fixers = {
\   'elixir': ['mix_format'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'javascriptreact': ['prettier', 'eslint'],
\   'typescriptreact': ['prettier', 'eslint']
\}

" Enable fixing on save
let g:ale_fix_on_save = 1

" Enable ALE linting in the background
" 'never' for on text changed, means it won't lint as you type
let g:ale_lint_on_text_changed = 'never'
" Lint when you leave insert mode
let g:ale_lint_on_insert_leave = 1
