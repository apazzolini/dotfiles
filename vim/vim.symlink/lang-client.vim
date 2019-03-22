let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_serverCommands = {
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['/usr/local/bin/javascript-typescript-stdio'],
    \ }

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=menuone,noselect
set shortmess+=c

let g:neosnippet#scope_aliases = {}
let g:neosnippet#scope_aliases['javascript.jsx'] = 'javascript'
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
    return "\<Plug>(ncm2_manual_trigger)"
  endif
endfunction

imap <expr><TAB> <SID>neosnippet_complete_tab()
inoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
inoremap <C-Space> <Plug>(ncm2_manual_trigger)

call ncm2#override_source('cwdpath', {'enable': 0})
