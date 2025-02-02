return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gL', ':Gclog -- %<cr>')
      vim.keymap.set('n', '<leader>gb', ':Git blame<cr>')
    end,
  },
  {
    'ruifm/gitlinker.nvim',
    config = function()
      require('gitlinker').setup({})
    end,
  },
  {
    'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup({})
    end,
  },
}

-- See also: gitsigns
