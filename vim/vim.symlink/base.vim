set ignorecase
set smartcase
set hlsearch
set incsearch

set autoindent
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

set signcolumn=yes
set number
set relativenumber
set colorcolumn=111

set vb t_vb=
set t_ut=
set timeoutlen=1000 ttimeoutlen=0
set autoread
set hidden
set wrap linebreak nolist
set splitright
set backspace=indent,eol,start
set nolazyredraw
set shiftround
set cinoptions+=+1
set noshowmatch
set noshowcmd
set switchbuf=useopen
set scrolloff=3
set nomodeline

set formatoptions+=j " Delete comment character when joining commented lines
set formatoptions-=co
set nojoinspaces

set foldmethod=manual
set nofoldenable
set foldlevel=99
set foldnestmax=4

set completefunc=LanguageClient#complete
set omnifunc=LanguageClient#complete

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

if has('nvim')
  set mouse=a
  set inccommand=split
endif

" Convenience Bindings
map ' `
let mapleader = ","
map Y y$
map ; :
map H 0
map L $
map <Space> 10j
map <BS> 10k
map <C-N> :tabnext<CR>
map <C-B> :tabprev<CR>
noremap j gj
noremap k gk
noremap <ScrollWheelUp> <C-Y>
noremap <ScrollWheelDown> <C-E>
map gz :tab sp<CR>
map gx :tabclose<CR>
nnoremap <c-d> 10<c-d>zz
nnoremap <c-u> 10<c-u>zz
noremap 0 ^
noremap ^ 0
imap <c-l> <space>=><space>
nnoremap <silent> <cr> :noh<cr>:syntax sync fromstart<cr><cr>
nnoremap <leader>G :G<cr>

" Only show cursor line on active split
set nocursorline
augroup Andre
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline

  autocmd BufReadPost *.tsx,*.ts,*.jsx,*.js syntax sync fromstart
  au BufRead,BufNewFile *.jsx set filetype=javascript.jsx

  autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

  " Strip trailing spaces and newlines on save
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre * %s#\($\n\s*\)\+\%$##e
augroup END

" Show syntax highlighting of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Split mappings
nnoremap c<C-j> :bel new<cr>
nnoremap c<C-k> :abo new<cr>
nnoremap c<C-h> :lefta vnew<cr>
nnoremap c<C-l> :rightb vnew<cr>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

map <leader>nt :tabnew<cr>

nnoremap <leader><leader> <c-^>

vmap <leader>y "*y
map <leader>p "*p

map <leader>jst :silent !stree<cr>
map <leader>jsf :silent !fork<cr>

map <leader>we :set winheight=999<cr>
map <leader>wd :set winheight=10<cr><c-w>=<cr>
map <leader>wj :resize +20<cr>
map <leader>wk :resize -20<cr>
map <leader>wh :vert resize -20<cr>
map <leader>wl :vert resize +20<cr>

nmap <leader>ot mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T
nmap <leader>oa mT?test(<cr>cetest.only<esc>'T
nmap <leader>ox mT:%s/test.only/test/ge<cr>'T

command! CopyPath let @* = expand("%:p")

command! BC call s:CloseHiddenBuffers()
function! s:CloseHiddenBuffers()
  let open_buffers = []

  for i in range(tabpagenr('$'))
    call extend(open_buffers, tabpagebuflist(i + 1))
  endfor

  for num in range(1, bufnr("$") + 1)
    if buflisted(num) && index(open_buffers, num) == -1
			exec "bdelete ".num
		endif
	endfor
endfunction

nnoremap <leader>W :Rg! <c-r><c-w><cr>

nmap <silent> [q :call qf#wrap#WrapCommand('up', 'c')<CR>
nmap <silent> ]q :call qf#wrap#WrapCommand('down', 'c')<CR>
