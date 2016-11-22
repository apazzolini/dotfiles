let g:neomake_open_list = 2
let g:neomake_javascript_enabled_makers = ['eslint']

let g:neomake_warning_sign = {
  \ 'text': 'w',
  \ 'texthl': 'Exception',
  \ }
let g:neomake_error_sign = {
  \ 'text': '>>',
  \ 'texthl': 'Error',
  \ }

au BufEnter *.js let b:neomake_javascript_eslint_exe = 'eslint_d'
autocmd! BufWinEnter,BufWritePost * Neomake
autocmd BufUnload * lclose
