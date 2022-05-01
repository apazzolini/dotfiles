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

set timeoutlen=500 ttimeoutlen=0
set autoread
set hidden
set updatetime=200
set shortmess+=c
set secure
set noswapfile
set nobackup
set nowritebackup
set wrap linebreak breakindent nolist
set splitright
set backspace=indent,eol,start
set lazyredraw
set noshowcmd
set switchbuf=useopen
set nomodeline
set mouse=a
set inccommand=split
set completeopt=menuone,noselect
set pumheight=20

set nojoinspaces

set foldmethod=manual
set nofoldenable
set foldlevel=99
set foldnestmax=4

let b:javascript_fold = 0
let g:javascript_plugin_jsdoc = 1
let g:jsx_ext_required = 0

set breakindent
set breakindentopt=shift:2
set showbreak=\\\\\

" Convenience mappings
map ; :
map ' `
map Y y$
map H 0
map L $
noremap j gj
noremap k gk
nnoremap <c-d> 10<c-d>zz
nnoremap <c-u> 10<c-u>zz
nnoremap <c-e> 3<c-e>
nnoremap <c-y> 3<c-y>
noremap 0 0^
noremap ^ 0
map gx :tabclose<CR>
nmap gq :q<cr>
nnoremap <silent> <cr> :noh<cr><cr>
nnoremap <leader><leader> <c-^>
map <leader>R :source $MYVIMRC<cr>
imap <c-l> <space>=><space>
xnoremap L g_
vmap <leader>y "+y
xnoremap <leader>p "_dP
cmap <c-k> <up>
cmap <c-j> <down>

" Disable mouse pasting
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>

" New ones
nnoremap <c-o> <c-o>zz
nnoremap <c-i> <c-i>zz
nnoremap n nzz
nnoremap N Nzz
nnoremap J mzJ`z

" Break undo sequence at punctuation marks
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Move lines up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Increment / decrement numbers
set nrformats=
nnoremap + <C-a>
nnoremap - <C-x>
xnoremap + g<C-a>
xnoremap - g<C-x>

" Split / tab mappings
nnoremap <leader>nt :tabnew<cr>
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

" Window zooming
map <leader>we :set winheight=999<cr>
map <leader>wd :set winheight=10<cr><c-w>=<cr>

" Test mappings
nmap <leader>ot mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T
nmap <leader>oa mT?test(<cr>cetest.only<esc>'T
nmap <leader>ox mT:%s/test.only/test/ge<cr>'T

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

" Make splits equal when resizing vim
autocmd VimResized * :wincmd =

" Close all hidden buffers
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

" Smart indent when entering insert mode with i on empty lines
function! IndentWith(default)
    if len(getline('.')) == 0
        return "\"_cc"
    else
        return a:default
    endif
endfunction
nnoremap <expr> a IndentWith("a")
nnoremap <expr> i IndentWith("i")

" Show treesitter highlights
nnoremap <leader>sh <cmd>TSHighlightCapturesUnderCursor<CR>

" Format JSON
function! s:FormatJSON()
  exe "%!/usr/bin/python -m 'json.tool'"
  set ft=json
endfunction
command! JSON call s:FormatJSON()

" Reload treesitter and LSP
function! s:ReloadTSLSP()
  write
  edit
  TSBufEnable highlight
  LspStop
  sleep 1
  LspStart
endfunction
command! ReloadTSLSP call s:ReloadTSLSP()
nnoremap <leader>k <cmd>ReloadTSLSP<cr>
