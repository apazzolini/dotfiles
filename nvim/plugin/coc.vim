"set cmdheight=2  " Give more space for displaying messages.
set shortmess+=c " Don't pass messages to |ins-completion-menu|.

let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#snippets_directory=$HOME.'/.dotfiles/nvim/snippets'

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

"autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

imap <expr><TAB> <SID>neosnippet_complete_tab()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr><CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
inoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"nmap <silent> <leader>nl :CocDiagnostics<cr>
nnoremap <silent><nowait> <leader>D  :<C-u>CocList diagnostics<cr>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
