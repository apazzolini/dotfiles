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
Plug 'nvim-telescope/telescope-fzf-writer.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'shadmansaleh/lualine.nvim'
Plug 'phaazon/hop.nvim'
Plug 'ThePrimeagen/harpoon'
Plug 'voldikss/vim-floaterm'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'tpope/vim-commentary'
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-entire'

" Replace these with something else
Plug 'Shougo/neosnippet.vim'
Plug 'rbong/vim-flog'

" Still evaluating ---------------------------------------------------------------------------------

Plug 'nikvdp/ejs-syntax'
" Plug 'hrsh7th/vim-vsnip'
" Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
" Plug 'ThePrimeagen/git-worktree.nvim'
" Plug 'nvim-telescope/telescope-project.nvim'
" Plug 'sindrets/diffview.nvim'
" Plug 'ivalkeen/vim-simpledb'
" Plug 'RishabhRD/nvim-lsputils'
" Plug 'TimUntersberger/neogit'
" Plug 'rhysd/git-messenger.vim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'
Plug 'folke/lua-dev.nvim'
Plug 'jason0x43/vim-js-indent'
Plug 'rhysd/clever-f.vim'
Plug 'pwntester/octo.nvim'

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
  " let g:SimplenoteSingleWindow=1
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
set guifont="Operator Mono Book":h8
set notermguicolors
colorscheme wave

lua << EOF
  for k, v in pairs(package.loaded) do
    if string.match(k, "^andre") then
      package.loaded[k] = nil
    end
  end
EOF

" autocmd! BufWritePost ~/.dotfiles/nvim/*.vim source $MYVIMRC
" autocmd! BufWritePost ~/.dotfiles/nvim/*.lua source $MYVIMRC
" autocmd! BufWritePost ~/.dotfiles/nvim/*.lua execute 'luafile %' | source $MYVIMRC

lua require('andre')
