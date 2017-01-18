" Basic configuration
set ic
set scs
set nohlsearch
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
set splitbelow
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
set termguicolors

" Convenience Bindings
map ' `
let mapleader = ","
map Y y$
map ; :
map H ^
map L $
map <C-B> <C-6>
map S i<CR><Esc>k$
nmap K kJ
map <Space> 10j
map <BS> 10k
map <C-n> :tabnext<CR>
map <C-p> :tabprev<CR>
inoremap jj <Esc>
noremap j gj
noremap k gk
vmap <leader>y "*y
map <leader>n :noh<cr>
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-H> <C-W>h
map <C-L> <C-W>l
nnoremap vv v$
nnoremap <leader>sv :source $MYVIMRC<CR>     
nmap <Tab> >
nmap <S-Tab> <
map <C-Y> <S-Tab>

"map <D-v> "*p
"imap <D-v> <Esc>"*pa

autocmd FileType javascript autocmd BufWritePre <buffer> :%s/\s\+$//e
