vim.g.mapleader = ','

require('andre.cmp')
require('andre.dap')
require('andre.colorizer')
require('andre.gitsigns')
require('andre.harpoon')
require('andre.hop')
require('andre.lsp')
require('andre.lualine')
require('andre.luasnip')
require('andre.nvimtree')
require('andre.surround')
require('andre.telescope')
require('andre.treesitter')

require('andre.autopairs') -- this has to load after cmp

require('nvim-lastplace').setup({})
