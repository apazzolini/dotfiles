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
set t_ut= 
set timeoutlen=1000 ttimeoutlen=0
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1

if has('nvim')
    set mouse=a
    set inccommand=split
endif

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
map <C-N> :tabnext<CR>
map <C-B> :tabprev<CR>
noremap j gj
noremap k gk
vmap <leader>y "*y
map <leader>n :noh<cr>
nnoremap <leader>sv :source $MYVIMRC<CR>     
noremap <ScrollWheelUp> 20<C-Y>
noremap <ScrollWheelDown> 20<C-E>
map <C-c> :read !pbpaste<CR>
imap <C-c> <Esc>:read !pbpaste<CR>
map <leader>we <C-W>=
map <leader>re :redraw!<CR>
map <leader>. :try<bar>lnext<bar>catch /^Vim\%((\a\+)\)\=:E\%(553\<bar>42\):/<bar>lfirst<bar>endtry<cr>
map gz :tab sp<CR>
map gZ :tabclose<CR>

" Show syntax highlighting of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
