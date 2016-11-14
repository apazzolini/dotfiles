set completeopt-=preview
set completeopt+=noinsert

let g:deoplete#enable_at_startup = 0

inoremap <expr><C-Space> deoplete#manual_complete()
inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<TAB>" :
\ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

autocmd FileType javascript call deoplete#enable() 
