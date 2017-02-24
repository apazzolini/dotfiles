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
set foldmethod=syntax
set foldnestmax=3
set foldlevel=3
set nofoldenable

if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end

" Change cursor based on mode
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
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
map <C-M> :tabnext<CR>
map <C-N> :tabprev<CR>
noremap j gj
noremap k gk
vmap <leader>y "*y
map <leader>n :noh<cr>
nnoremap <leader>sv :source $MYVIMRC<CR>     
nmap <Tab> >
nmap <S-Tab> <
map <C-Y> <S-Tab>
noremap <ScrollWheelUp> 9<C-Y>
noremap <ScrollWheelDown> 9<C-E>
"map <C-c> o<Esc>"*p']
"imap <C-c> <Esc>"*p']a
map <C-c> :read !pbpaste<CR>
imap <C-c> <Esc>:read !pbpaste<CR>
map <leader>we <C-W>=
map <leader>re :redraw!<CR>

" Show syntax highlighting of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

autocmd FileType javascript autocmd BufWritePre <buffer> :%s/\s\+$//e
