let g:neomake_open_list = 2

let g:neomake_warning_sign = {
  \ 'text': 'w',
  \ 'texthl': 'Exception',
  \ }
let g:neomake_error_sign = {
  \ 'text': '>>',
  \ 'texthl': 'Error',
  \ }

"let g:neomake_javascript_eslint_exe = 'eslint_d'

function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

let g:neomake_javascript_enabled_makers = ['eslint_d']

let g:flow_path = StrTrim(system('PATH=$(npm bin):$PATH && which flow'))
if findfile('.flowconfig', '.;') !=# ''
  let g:flow_path = StrTrim(system('PATH=$(npm bin):$PATH && which flow'))
  if g:flow_path != 'flow not found'
    let g:neomake_javascript_flow_maker = {
          \ 'exe': 'sh',
          \ 'args': ['-c', g:flow_path.' --json 2> /dev/null | flow-vim-quickfix'],
          \ 'errorformat': '%E%f:%l:%c\,%n: %m',
          \ 'cwd': '%:p:h'
          \ }
    let g:neomake_javascript_enabled_makers = g:neomake_javascript_enabled_makers + ['flow']
  endif
endif

" This is kinda useful to prevent Neomake from unnecessary runs
if !empty(g:neomake_javascript_enabled_makers)
  autocmd! BufWritePost * Neomake
endif

autocmd BufUnload * lclose
