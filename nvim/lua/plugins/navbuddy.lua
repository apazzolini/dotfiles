return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'SmiteshP/nvim-navbuddy',
      dependencies = {
        'SmiteshP/nvim-navic',
        'MunifTanjim/nui.nvim',
      },
      opts = { lsp = { auto_attach = true } },
    },
  },
  config = function()
    vim.keymap.set('n', 'gk', function()
      require('nvim-navbuddy').open()
    end)
  end,
  -- your lsp config or other stuff
}
