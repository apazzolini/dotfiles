augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.js,*.css,*.html call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:syntastic_reuse_loc_lists = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = 'eslint_d'
let g:syntastic_javascript_eslint_args = '--parser=babel-eslint'
let g:syntastic_mode_map = { 'mode': 'passive' }
nnoremap <C-w>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>
