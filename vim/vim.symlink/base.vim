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
set t_ut= 

if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end

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
map <C-M> :tabnext<CR>
map <C-N> :tabprev<CR>
"inoremap jj <Esc>
noremap j gj
noremap k gk
vmap <leader>y "*y
map <leader>n :noh<cr>
"map <C-J> <C-W>j
"map <C-K> <C-W>k
"map <C-H> <C-W>h
"map <C-L> <C-W>l
"nnoremap vv v$
nnoremap <leader>sv :source $MYVIMRC<CR>     
nmap <Tab> >
nmap <S-Tab> <
map <C-Y> <S-Tab>
noremap <ScrollWheelUp>     9<C-Y>
noremap <ScrollWheelDown>   9<C-E>
map <C-c> "*p
imap <C-c> <Esc>"*pa

autocmd FileType javascript autocmd BufWritePre <buffer> :%s/\s\+$//e
