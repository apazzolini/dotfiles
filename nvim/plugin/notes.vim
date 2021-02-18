if (!g:isNotes)
  finish
endif

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
imap <c-v> <c-r>*

hi MatchParen ctermfg=0

augroup ActiveCursorLine
  autocmd!
augroup END

if (has('win32'))
  let wikipath = 'C:/Users/andre/iCloudDrive/Wiki'
else
  let wikipath = '/Users/andre/Library/Mobile Documents/com~apple~CloudDocs/Wiki'
endif

cd `=wikipath`

let g:vimwiki_list = [{'path': wikipath, 'ext': '.md'}]
let g:vimwiki_autowriteall = 0
