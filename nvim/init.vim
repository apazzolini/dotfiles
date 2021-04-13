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

Plug 'apazzolini/nerdtree'

Plug 'sickill/vim-pasta'
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
Plug 'szw/vim-maximizer'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'godlygeek/tabular'
Plug 'rbong/vim-flog'
Plug 'sbdchd/neoformat'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'phaazon/hop.nvim'

Plug 'tmsvg/pear-tree'
" Plug 'jiangmiao/auto-pairs'
" Plug 'windwp/nvim-autopairs'
" Plug 'cohama/lexima.vim'

" Replace these with something else
" Plug 'easymotion/vim-easymotion'
" Plug 'AndrewRadev/splitjoin.vim'
" Plug 'gavocanov/vim-js-indent'

" Still evaluating ---------------------------------------------------------------------------------

Plug 'ivalkeen/vim-simpledb'

" --------------------------------------------------------------------------------------------------

if !empty($TMUX)
  Plug 'tmux-plugins/vim-tmux-focus-events'
  Plug 'apazzolini/vim-tmux-navigator', {'branch': 'indicator'}
  let g:tmux_navigator_disable_when_zoomed = 1
endif

if (g:isNotes)
  Plug 'vimwiki/vimwiki'
else
  Plug 'hrsh7th/nvim-compe'
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

lua << EOF
  for k, v in pairs(package.loaded) do
    if string.match(k, "^andre") then
      package.loaded[k] = nil
    end
  end
EOF

autocmd! BufWritePost ~/.dotfiles/nvim/*.vim source $MYVIMRC
autocmd! BufWritePost ~/.dotfiles/nvim/*.lua execute 'luafile %' | source $MYVIMRC

sign define LspDiagnosticsSignError text=>> texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text=> texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=> texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=> texthl=LspDiagnosticsSignHint linehl= numhl=

lua require('andre')
