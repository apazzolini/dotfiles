let g:neomake_open_list = 2

let g:neomake_warning_sign = {
  \ 'text': 'w',
  \ 'texthl': 'Exception',
  \ }
let g:neomake_error_sign = {
  \ 'text': '>>',
  \ 'texthl': 'Error',
  \ }

function PostprocessEslintD(entry)
    if (a:entry.lnum == 0)
        let a:entry.valid = -1
    endif
endfunction
let g:neomake_javascript_eslint_d_maker = {
    \ 'args': ['-f', 'compact'],
    \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
    \ '%W%f: line %l\, col %c\, Warning - %m',
    \ 'postprocess': function('PostprocessEslintD')
    \ }

let g:neomake_javascript_enabled_makers = ['eslint_d']
let g:neomake_html_enabled_makers = []

autocmd! BufWritePost *.js Neomake
autocmd BufUnload * lclose

" function! neomake#makers#ft#javascript#StripExtraLines(entry) abort
    " echom string(a:entry)
    " if (a:entry.valid == 0)
        " let a:entry.valid = -1
    " endif
    " echom string(a:entry)
" endfunction

