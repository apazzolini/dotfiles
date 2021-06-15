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
set shiftround

set signcolumn=yes
set number
set relativenumber
set scrolloff=4
set colorcolumn=

set timeoutlen=750 ttimeoutlen=0
set autoread
set hidden
set updatetime=200
set shortmess+=c
set secure
set noswapfile
set nobackup
set nowritebackup
set wrap linebreak nolist
set splitright
set backspace=indent,eol,start
set lazyredraw
" set cinoptions+=+1
" set noshowmatch
set noshowcmd
set switchbuf=useopen
set nomodeline
set mouse=a
set inccommand=split
set completeopt=menuone,noselect

set nojoinspaces
autocmd FileType * set formatoptions-=o
autocmd FileType * set formatoptions+=j
" autocmd FileType * set formatoptions-=c

set foldmethod=manual
set nofoldenable
set foldlevel=99
set foldnestmax=4

" ------------------------------------------------------------------------------

" Convenience mappings
map ' `
let mapleader = ","
map Y y$
map H 0
map L $
noremap j gj
noremap k gk
map gx :tabclose<CR>
nnoremap <c-d> 10<c-d>
nnoremap <c-u> 10<c-u>
" nnoremap <c-d> 10<c-d>zz
" nnoremap <c-u> 10<c-u>zz
nnoremap <c-e> 3<c-e>
nnoremap <c-y> 3<c-y>
noremap 0 0^
noremap ^ 0
imap <c-l> <space>=><space>
nnoremap <silent> <cr> :noh<cr><cr>
map <leader>nt :tabnew<cr>
nnoremap <leader><leader> <c-^>
vmap <leader>y "*y
map <leader>jst :silent !stree<cr>
map <leader>k :write <bar> edit <bar> TSBufEnable highlight<cr>
map <leader>R :source ~/.config/nvim/init.vim<cr>
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
" map <leader>ww :w <bar> source %<cr>
map ; :
" nnoremap : ;
" map <Space> 10j
" map <BS> 10k
" map <leader>p "*p
nmap gq :q<cr>
nmap gQ :qa<cr>

" Split mappings
nnoremap c<C-j> :bel new<cr>
nnoremap c<C-k> :abo new<cr>
nnoremap c<C-h> :lefta vnew<cr>
nnoremap c<C-l> :rightb vnew<cr>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <a-[> gT
nnoremap <a-]> gt
map <leader>we :set winheight=999<cr>
map <leader>wd :set winheight=10<cr><c-w>=<cr>
map <leader>wj :resize +20<cr>
map <leader>wk :resize -20<cr>
map <leader>wh :vert resize -20<cr>
map <leader>wl :vert resize +20<cr>

" Test mappings
nmap <leader>ot mT:%s/it.only/it/ge<cr>'T?it(<cr>ceit.only<esc>'T
nmap <leader>oa mT?it(<cr>ceit.only<esc>'T
nmap <leader>ox mT:%s/it.only/it/ge<cr>'T

" Only show cursor line on active split
set nocursorline
augroup ActiveCursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

" Strip trailing spaces and newlines on save
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s#\($\n\s*\)\+\%$##e

" Restore last position when reopening file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Move cursor to first line in insert mode on git commits
autocmd FileType gitcommit execute "normal! gg" | startinsert

" Show syntax highlighting of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

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

"smart indent when entering insert mode with i on empty lines
function! IndentWith(default)
    if len(getline('.')) == 0
        return "\"_cc"
    else
        return a:default
    endif
endfunction

nnoremap <expr> a IndentWith("a")
nnoremap <expr> i IndentWith("i")
