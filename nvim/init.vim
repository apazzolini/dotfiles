" ------------------------------------------------------------------------------
" Environment detection --------------------------------------------------------
" ------------------------------------------------------------------------------

let g:isNotes = argc() >= 1 && argv()[0] == 'D:\Air\Wiki\diary\diary.md'
let g:home = has('win32') ? 'L:/home/andre' : has('osx') ? '/Users/andre' : '/home/andre'
let g:pluggedHome = has('win32')
  \ ? 'C:/Users/andre/AppData/Local/nvim-data/plugged'
  \ : '~/.dotfiles/nvim/plugged'

" ------------------------------------------------------------------------------
" Plugins ----------------------------------------------------------------------
" ------------------------------------------------------------------------------

call plug#begin(g:pluggedHome)

Plug 'apazzolini/vim-wave'
Plug 'apazzolini/nerdtree'
Plug 'sickill/vim-pasta'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'wellle/targets.vim'
Plug 'romainl/vim-qf'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'fvictorio/vim-textobj-backticks'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'Shougo/neosnippet.vim'
Plug 'tmsvg/pear-tree'
Plug 'easymotion/vim-easymotion'
Plug 'szw/vim-maximizer'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'godlygeek/tabular'
Plug 'rbong/vim-flog'

" Still evaluating -------------------------------------------------------------
Plug 'ivalkeen/vim-simpledb'
" ------------------------------------------------------------------------------

if !empty($TMUX)
  Plug 'apazzolini/vim-tmux-navigator', {'branch': 'indicator'}
  Plug 'tmux-plugins/vim-tmux-focus-events'
  let g:tmux_navigator_disable_when_zoomed = 1
endif

if (g:isNotes)
  Plug 'vimwiki/vimwiki'
endif

call plug#end()

filetype plugin indent on
syntax enable

" ------------------------------------------------------------------------------
" Colorscheme ------------------------------------------------------------------
" ------------------------------------------------------------------------------

exec 'set background=' . (g:isNotes ? 'light' : 'dark')
set guifont=Operator\ Mono:h8
set termguicolors
colorscheme wave

silent! source ./.vimlocal

"lua require'colorizer'.setup()
