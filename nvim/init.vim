let g:isNotes = argc() >= 1 && argv()[0] == 'D:\Air\Wiki\diary\diary.md'
let g:home = has('win32') ? 'L:/home/andre' : has('osx') ? '/Users/andre' : '/home/andre'
let g:pluggedHome = has('win32')
  \ ? 'C:/Users/andre/AppData/Local/nvim-data/plugged'
  \ : '~/.dotfiles/nvim/plugged'

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

if exists("g:nvy")
  Plug 'norcalli/nvim-colorizer.lua'
endif

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

exec 'set background=' . (g:isNotes ? 'light' : 'dark')
colorscheme wave

set guifont=Operator\ Mono:h8

exec 'source ' . g:home . '/.dotfiles/nvim/base.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/easymotion.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/fillline.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/fzf.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/lightline.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/maximizer.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/neosnippet.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/nerdcommenter.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/nerdtree.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/pear-tree.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/qf.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/surround.vim'
exec 'source ' . g:home . '/.dotfiles/nvim/targets.vim'

silent! source ./.vimlocal

if (g:isNotes)
  exec 'source ' . g:home . '/.dotfiles/nvim/notes.vim'
endif

if exists("g:nvy")
  set termguicolors
  lua require'colorizer'.setup()
endif
