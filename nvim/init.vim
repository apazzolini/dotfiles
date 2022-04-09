" --------------------------------------------------------------------------------------------------
" Environment detection ----------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

let g:isNotes = expand('$IS_NOTES') == 1 || (argc() >= 1 && argv()[0] =~ 'index.md')
let g:home = has('win32') ? 'L:/home/andre' : has('osx') ? '/Users/andre' : '/home/andre'
let g:pluggedHome = has('win32')
  \ ? 'C:/Users/andre/AppData/Local/nvim-data/plugged'
  \ : '~/.dotfiles/nvim/plugged'

" --------------------------------------------------------------------------------------------------
" Plugins ------------------------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(g:pluggedHome)

Plug 'kyazdani42/nvim-tree.lua'
Plug 'sickill/vim-pasta'
Plug 'tpope/vim-surround'
Plug 'romainl/vim-qf'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'szw/vim-maximizer'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'godlygeek/tabular'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/playground'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'nvim-lualine/lualine.nvim'
Plug 'phaazon/hop.nvim'
Plug 'ThePrimeagen/harpoon'
Plug 'voldikss/vim-floaterm'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'tpope/vim-commentary'
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-entire'
Plug 'rhysd/clever-f.vim'

" Still evaluating ---------------------------------------------------------------------------------

Plug 'nikvdp/ejs-syntax'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'folke/lua-dev.nvim'
" Plug 'pwntester/octo.nvim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'pangloss/vim-javascript'
" Plug 'kyazdani42/nvim-web-devicons'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

" --------------------------------------------------------------------------------------------------

if !empty($TMUX)
  Plug 'apazzolini/vim-tmux-navigator', {'branch': 'indicator'}
  let g:tmux_navigator_disable_when_zoomed = 1
endif

if (g:isNotes)
  Plug 'vimwiki/vimwiki'
  Plug 'simplenote-vim/simplenote.vim'
  source ~/.simplenoterc
  command SN SimplenoteOpen 24176b52e39845c7904d4500da8157df
else
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'windwp/nvim-autopairs'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'
endif

call plug#end()

filetype plugin indent on
syntax enable

" --------------------------------------------------------------------------------------------------
" Colorscheme --------------------------------------------------------------------------------------
" --------------------------------------------------------------------------------------------------

exec 'set background=' . (g:isNotes ? 'light' : 'dark')
set guifont="Operator Mono Book":h8
set termguicolors
colorscheme wave

lua << EOF
  for k, v in pairs(package.loaded) do
    if string.match(k, "^andre") then
      package.loaded[k] = nil
    end
  end
EOF

let b:javascript_fold = 0
let g:javascript_plugin_jsdoc = 1
let g:jsx_ext_required = 0

" autocmd! BufWritePost ~/.dotfiles/nvim/*.vim source $MYVIMRC
" autocmd! BufWritePost ~/.dotfiles/nvim/*.lua source $MYVIMRC
" autocmd! BufWritePost ~/.dotfiles/nvim/*.lua execute 'luafile %' | source $MYVIMRC

lua require('andre')
