" --------------------------------------------------------------------------------------------------
" Environment detection ----------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

let g:isNotes = argc() >= 1 && argv()[0] =~ 'diary.md'
let g:home = has('win32') ? 'L:/home/andre' : has('osx') ? '/Users/andre' : '/home/andre'
let g:pluggedHome = has('win32')
  \ ? 'C:/Users/andre/AppData/Local/nvim-data/plugged'
  \ : '~/.dotfiles/nvim/plugged'

" --------------------------------------------------------------------------------------------------
" Plugins ------------------------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

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
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-entire'
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
Plug 'sbdchd/neoformat'
Plug 'alvan/vim-closetag'

" Still evaluating ---------------------------------------------------------------------------------
Plug 'ivalkeen/vim-simpledb'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'MaxMEllon/vim-jsx-pretty'

"Plug 'neovim/nvim-lspconfig'
"Plug 'fvictorio/vim-textobj-backticks'
"Plug 'sheerun/vim-polyglot'
"Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
" --------------------------------------------------------------------------------------------------

if !empty($TMUX)
  Plug 'tmux-plugins/vim-tmux-focus-events'
  Plug 'apazzolini/vim-tmux-navigator', {'branch': 'indicator'}
  let g:tmux_navigator_disable_when_zoomed = 1
endif

if (g:isNotes)
  Plug 'vimwiki/vimwiki'
else
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

call plug#end()

filetype plugin indent on
syntax enable

" --------------------------------------------------------------------------------------------------
" Colorscheme --------------------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

exec 'set background=' . (g:isNotes ? 'light' : 'dark')
set guifont=Consolas:h8
set termguicolors
colorscheme wave

lua require('init')
