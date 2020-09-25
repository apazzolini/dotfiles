let g:ale_linters_explicit = 1

" let g:ale_linters = {
" \   'javascript': ['eslint'],
" \   'typescript': ['eslint'],
" \}
let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\}
" let g:ale_javascript_eslint_use_global = 1
" let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_prettier_use_global = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:ale_javascript_prettier_executable = 'prettier_d_slim'

" let g:ale_hover_cursor = 0
" let g:ale_open_list = 0
" let g:ale_lint_on_enter = 1
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1

nmap <silent> <leader>nl <Plug>(ale_next_wrap)
" nmap <silent> [g <Plug>(ale_previous_wrap)
" nmap <silent> ]g <Plug>(ale_next_wrap)
nmap <silent> <leader>nf <Plug>(ale_fix)

" nmap <silent> gd :YcmCompleter GoToDefinition<cr>
" nmap <silent> gr :ALEFindReferences<cr>
" nmap <silent> K :ALEHover<cr>

function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

nmap <silent> <leader>L :call ToggleList("Location List", 'l')<CR>

" set completeopt-=preview
" let g:deoplete#enable_at_startup = 1
