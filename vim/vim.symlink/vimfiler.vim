let g:vimfiler_ignore_pattern = ['^\.', '^es5', '^dist', '^node_modules', '^coverage']
let g:vimfiler_as_default_explorer = 1

map <leader>g :VimFiler -fnamewidth=120 -find<CR>

autocmd FileType vimfiler call s:vimfiler_settings()
function! s:vimfiler_settings()
    nnoremap <silent><buffer><expr> s vimfiler#do_switch_action('split')
    nnoremap <silent><buffer><expr> v vimfiler#do_switch_action('vsplit')
    setlocal norelativenumber
    setlocal nonumber
    nmap <buffer> <Space> 10j
    nmap <buffer> <BS>    10k
endfunction
