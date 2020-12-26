set shortmess+=c
set completeopt=menu,menuone,noinsert

let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#snippets_directory=$HOME.'/.vim/snippets'

function! s:neosnippet_complete_tab()
  let col = col('.') - 1
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif pumvisible()
    return "\<c-n>"
  elseif !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return coc#refresh()
  endif
endfunction

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

imap <expr><TAB> <SID>neosnippet_complete_tab()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr><CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
inoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> K :call CocAction('doHover')<cr>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
