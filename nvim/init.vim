call plug#begin('~/.config/nvim/plugged')

" Generic plugins
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'
Plug 'sickill/vim-pasta'
Plug 'raimondi/delimitmate'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-surround'
Plug 'mrtazz/simplenote.vim'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdcommenter'
Plug 'bkad/CamelCaseMotion'
Plug 'neomake/neomake'
Plug 'mileszs/ack.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'  }
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'Shougo/unite.vim'

" Filetype specific plugins
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern', 'for': 'javascript' }
Plug 'apazzolini/vim-javascript', { 'for': 'javascript' }

" Colorschemes
Plug 'chriskempson/base16-vim'

call plug#end()

filetype plugin indent on
syntax enable

colorscheme base16-eighties

source ~/.config/nvim/base.vim
source ~/.config/nvim/ack.vim
source ~/.config/nvim/neovim.vim
source ~/.config/nvim/camelcasemotion.vim
source ~/.config/nvim/delimitmate.vim
source ~/.config/nvim/fillline.vim
source ~/.config/nvim/lightline.vim
source ~/.config/nvim/nerdcommenter.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/neomake.vim
source ~/.config/nvim/simplenote.vim
source ~/.config/nvim/deoplete.vim
source ~/.config/nvim/deoplete-tern.vim
source ~/.config/nvim/unite.vim
