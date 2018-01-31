set completeopt=noselect,menuone

let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 0
let g:deoplete#file#enable_buffer_path = 1

let g:tern_request_timeout = 1
let g:tern_show_signature_in_pum = '1'

inoremap <expr><C-space> deoplete#manual_complete()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"

" I want to use my tab more smarter. If we are inside a completion menu jump
" to the next item. Otherwise check if there is any snippet to expand, if yes
" expand it. Also if inside a snippet and we need to jump tab jumps. If none
" of the above matches we just call our usual 'tab'.
function! s:neosnippet_complete()
  if pumvisible()
    return "\<c-y>"
  else
    if neosnippet#expandable_or_jumpable()
      return "\<Plug>(neosnippet_expand_or_jump)"
    endif
    return "\<Plug>delimitMateCR"
  endif
endfunction

function! s:neosnippet_complete_jj()
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  else
    return deoplete#manual_complete()
  endif
endfunction

function! s:neosnippet_complete_tab()
  let col = col('.') - 1
  if neosnippet#expandable_or_jumpable()
    return "\<Plug>(neosnippet_expand_or_jump)"
  elseif pumvisible()
    return "\<c-n>"
  elseif !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return deoplete#manual_complete()
  endif
endfunction

imap <expr><TAB> <SID>neosnippet_complete_tab()
imap <expr>jj <SID>neosnippet_complete_jj()
"imap <expr><CR> <SID>neosnippet_complete()

let g:deoplete#ignore_sources = {}
let g:deoplete#ignore_sources._ = ["neosnippet","LanguageClient"]
let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#snippets_directory=$HOME.'/.vim/snippets'

function! DeopleteDisable()
  let g:deoplete#disable_auto_complete = 1
endfunction
command! DeopleteDisable call DeopleteDisable()

function! DeopleteEnable()
  let g:deoplete#disable_auto_complete = 0
endfunction
command! DeopleteEnable call DeopleteEnable()
