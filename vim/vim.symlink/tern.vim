let g:tern#command = ["node", '/Users/Andre/.vim/plugged/tern_for_vim/node_modules/tern/bin/tern', '--no-port-file', '--persistent']
let g:tern_show_signature_in_pum = 1
let g:tern_map_keys = 0
let g:tern_request_timeout = 2
nmap gr :TernRefs<CR>
nmap gd :TernDef<CR>
autocmd FileType javascript python tern_ensureCompletionCached()
