" Basic configuration
set ic
set scs
set hlsearch
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set vb t_vb=
set incsearch
set number
set wrap linebreak nolist
set splitright
set formatoptions+=j " Delete comment character when joining commented lines
set sidescrolloff=5
set scrolloff=1
set autoread
set formatoptions-=co
set nojoinspaces
set backspace=indent,eol,start
set lazyredraw
set autoread
set shiftround
set cinoptions+=+1
set noshowmatch
set t_ut=
set timeoutlen=1000 ttimeoutlen=0
set foldmethod=manual
set nofoldenable
set hidden
set switchbuf=useopen
set scrolloff=10

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
map <C-B> <C-6>
map S i<CR><Esc>k$
map <Space> 10j
map <BS> 10k
map <C-N> :tabnext<CR>
map <C-B> :tabprev<CR>
noremap j gj
noremap k gk
noremap <ScrollWheelUp> <C-Y>
noremap <ScrollWheelDown> <C-E>
map <C-c> :read !pbpaste<CR>
imap <C-c> <Esc>:read !pbpaste<CR>
map gz :tab sp<CR>
map gx :tabclose<CR>
nnoremap zu 15<c-y>
nnoremap zd 15<c-e>
nnoremap 0 ^
nnoremap ^ 0

" Only show cursor line on active split
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

" Show syntax highlighting of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

autocmd! FileType mkd setlocal syn=off
autocmd BufWritePre * %s/\s\+$//e

set winwidth=120

set winheight=10
set winminheight=10
set winheight=999
nnoremap c<C-j> :bel sp new<cr>
nnoremap c<C-k> :abo sp new<cr>
nnoremap c<C-h> :lefta vsp new<cr>
nnoremap c<C-l> :rightb vsp new<cr>
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction

nnoremap <leader><leader> <c-^>
cnoremap <expr> %% expand('%:h').'/'
nnoremap <leader>W :source $MYVIMRC<CR>
vmap <leader>y "*y
map <leader>p "*p
map <leader>jst :silent !open -a "/Applications/SourceTree.app" `pwd`<cr>
map <leader>jsf :silent !open -a "/Applications/Fork.app" `pwd`<cr>
map <leader>json :%!python -m json.tool<cr>
map <leader>nr :call RenameFile()<cr>
map <leader>ne :e %%
map <leader>nt :tabnew<cr>

map <leader>we :set winheight=999<cr>
map <leader>wd :set winheight=10<cr><c-w>=<cr>
map <leader>wj :resize +20<cr>
map <leader>wk :resize -20<cr>
map <leader>wh :vert resize -20<cr>
map <leader>wl :vert resize +20<cr>

nmap <leader>wJ 15<C-e>
nmap <leader>wK 15<C-y>

nmap <leader>ot mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T
nmap <leader>oa mT?test(<cr>cetest.only<esc>'T
nmap <leader>ox mT:%s/test.only/test/ge<cr>'T
