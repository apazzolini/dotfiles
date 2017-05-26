set completeopt-=preview

if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.javascript = '[^. *\t]\.\w*\|\h\w*::'

inoremap <expr><C-space> neocomplete#start_manual_complete()
imap <C-@> <C-space>
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
imap <expr> <CR> pumvisible() ? "\<C-y>" : '<Plug>delimitMateCR'

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_auto_select = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#disable_auto_complete = 0
let g:neocomplete#auto_completion_start_length = 3
let g:neocomplete#sources#syntax#min_keyword_length = 4
let g:neocomplete#lock_buffer_name_pattern = '\v(\.md|\.txt|\.git\/COMMIT_EDITMSG)'

" Snippets
imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" :
let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#snippets_directory=$HOME.'/.vim/snippets'
