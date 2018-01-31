let g:ale_linters = {
\   'javascript': ['eslint'],
\}
let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_eslint_executable = 'eslint_d'

let g:ale_open_list = 0
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0

nmap <silent> <leader>nl <Plug>(ale_next_wrap)
