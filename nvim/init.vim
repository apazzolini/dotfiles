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
Plug 'mileszs/ack.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins'  }
Plug 'Shougo/vimproc.vim', {'do' : 'make'}

Plug 'christoomey/vim-tmux-navigator'
Plug 'wellle/targets.vim'

"Plug 'w0rp/ale'


Plug 'Shougo/unite.vim'
Plug 'neomake/neomake'

" Filetype specific plugins
Plug 'apazzolini/vim-javascript', { 'for': 'javascript' }
Plug 'wokalski/autocomplete-flow'

" Colorschemes
Plug 'chriskempson/base16-vim'

call plug#end()

filetype plugin indent on
syntax enable

let base16colorspace=256
colorscheme base16-tomorrow-night

source ~/.config/nvim/base.vim
source ~/.config/nvim/ack.vim
source ~/.config/nvim/camelcasemotion.vim
source ~/.config/nvim/delimitmate.vim
source ~/.config/nvim/fillline.vim
source ~/.config/nvim/lightline.vim
source ~/.config/nvim/nerdcommenter.vim
source ~/.config/nvim/nerdtree.vim
" source ~/.config/nvim/neomake.vim
source ~/.config/nvim/simplenote.vim
" source ~/.config/nvim/unite.vim

source ~/.config/nvim/neovim.vim
" source ~/.config/nvim/deoplete.vim

"
"
"
"
"source ~/.config/nvim/deoplete-tern.vim


let g:javascript_plugin_flow = 1

let g:ale_lint_on_text_changed = 'never'
let g:ale_javascript_eslint_executable = '/usr/local/bin/eslint_d'
let g:ale_javascript_eslint_use_global = 1
let g:ale_sign_column_always = 1
let g:ale_open_list = 1
let g:ale_linters = {
\   'javascript': ['flow', 'eslint'],
\}

let g:flow#enable = 0
