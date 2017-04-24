let g:neomake_open_list = 2

let g:neomake_warning_sign = {
  \ 'text': 'w',
  \ 'texthl': 'Exception',
  \ }
let g:neomake_error_sign = {
  \ 'text': '>>',
  \ 'texthl': 'Error',
  \ }

let g:neomake_javascript_enabled_makers = ['eslint_d']
let g:neomake_html_enabled_makers = []
let g:neomake_javascript_eslint_d_remove_invalid_entries = 1

autocmd! BufWritePost *.js Neomake
autocmd BufUnload * lclose
