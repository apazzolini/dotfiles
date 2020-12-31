set nocursorline
set norelativenumber
set winheight=10
set winwidth=10
set winminwidth=0
set winwidth=84
set laststatus=0
set noruler
set autoindent
set smartindent
set colorcolumn=999
set signcolumn=no
set matchpairs=

nmap <Leader>b <Plug>VimwikiGoBackLink

hi MatchParen ctermfg=0

augroup ActiveCursorLine
  autocmd!
augroup END

cd D:/Air/Wiki

let g:vimwiki_list = [{'path': 'D:/Air/Wiki', 'ext': '.md'}]
let g:vimwiki_autowriteall = 0
