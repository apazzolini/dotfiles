return {
  'tpope/vim-commentary',
  config = function()
    vim.keymap.set('n', '<leader>ct', 'gcc', { remap = true })
    vim.keymap.set('x', '<leader>ct', 'gc', { remap = true })
  end,
}
