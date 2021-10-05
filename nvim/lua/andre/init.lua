require('andre.colorizer')
require('andre.harpoon')
require('andre.hop')
require('andre.lsp')
require('andre.compe')
require('andre.lualine')
require('andre.telescope')
require('andre.treesitter')
require('andre.nvimtree')

require('nvim-autopairs').setup()

if pcall(require, 'compe') then
  require('nvim-autopairs.completion.compe').setup({
    map_cr = true, --  map <CR> on insert mode
    map_complete = true, -- it will auto insert `(` after select function or method item
  })
end
