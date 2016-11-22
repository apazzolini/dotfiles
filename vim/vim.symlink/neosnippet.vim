imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" :
let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#snippets_directory=$HOME.'/.config/nvim/snippets'

