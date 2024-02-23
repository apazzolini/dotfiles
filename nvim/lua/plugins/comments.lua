return {
  {
    'tpope/vim-commentary',
    config = function()
      vim.keymap.set('n', '<leader>ct', 'gcc', { remap = true })
      vim.keymap.set('x', '<leader>ct', 'gc', { remap = true })
    end,
  },
  { 'folke/todo-comments.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
}
