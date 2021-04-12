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
set colorcolumn=95

set timeoutlen=1000 ttimeoutlen=0
set autoread
set hidden
set updatetime=300
set shortmess+=c
set secure
set nobackup
set nowritebackup
set wrap linebreak nolist
set splitright
set backspace=indent,eol,start
set lazyredraw
set cinoptions+=+1
set noshowmatch
set noshowcmd
set switchbuf=useopen
set nomodeline
set mouse=a
set inccommand=split
set completeopt=menuone,noselect

set nojoinspaces
autocmd FileType * set formatoptions-=o
autocmd FileType * set formatoptions-=c
autocmd FileType * set formatoptions+=j

set foldmethod=manual
set nofoldenable
set foldlevel=99
set foldnestmax=4

" ------------------------------------------------------------------------------

" Convenience mappings
map ' `
let mapleader = ","
map Y y$
map ; :
map H 0
map L $
map <Space> 10j
map <BS> 10k
noremap j gj
noremap k gk
map gx :tabclose<CR>
nnoremap <c-d> 10<c-d>zz
nnoremap <c-u> 10<c-u>zz
noremap 0 ^
noremap ^ 0
imap <c-l> <space>=><space>
nnoremap <silent> <cr> :noh<cr><cr>
map <leader>nn :noh<cr>
map <leader>nt :tabnew<cr>
nnoremap <leader><leader> <c-^>
vmap <leader>y "*y
" map <leader>p "*p
map <leader>jst :silent !stree<cr>
map <leader>k :write <bar> edit <bar> TSBufEnable highlight<cr>
map <leader>ww :w <bar> source %<cr>
map <leader>wa :edit ~/.config/nvim/plugged/vim-wave/colors/wave.vim<cr>

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
nmap <leader>ot mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T
nmap <leader>oa mT?test(<cr>cetest.only<esc>'T
nmap <leader>ox mT:%s/test.only/test/ge<cr>'T

" Move cursor to first line in insert mode on git commits
autocmd FileType gitcommit execute "normal! gg" | startinsert

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

autocmd bufnewfile,bufread *.jsx set filetype=javascriptreact
