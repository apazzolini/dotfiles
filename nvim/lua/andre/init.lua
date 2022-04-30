require('andre.cmp')
require('andre.dap')
require('andre.colorizer')
require('andre.harpoon')
require('andre.hop')
require('andre.lsp')
require('andre.lualine')
require('andre.luasnip')
require('andre.nvimtree')
require('andre.octo')
require('andre.telescope')
require('andre.treesitter')
require('andre.autopairs') -- this has to load after cmp

local parsers = require('nvim-treesitter.parsers')
local configs = parsers.get_parser_configs()
local ft_str = table.concat(vim.tbl_map(function(ft) return configs[ft].filetype or ft end, parsers.available_parsers()), ',')
vim.cmd('autocmd Filetype ' .. ft_str .. ' setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()')

require('remember')
