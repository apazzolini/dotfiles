vim.g.maximizer_set_default_mapping = 0

return {
  'szw/vim-maximizer',
  config = function()
    vim.keymap.set('n', 'gz', ':MaximizerToggle!<CR>', { silent = true })
    vim.keymap.set('v', 'gz', ':MaximizerToggle!<CR>gv', { silent = true })
  end,
}
