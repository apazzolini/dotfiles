vim.g.floaterm_width = 0.95
vim.g.floaterm_opener = 'edit'
vim.g.floaterm_height = 0.98
vim.g.floaterm_position = 'top'

return {
  'voldikss/vim-floaterm',
  config = function()
    vim.keymap.set('n', '<c-g>', ':FloatermNew --autoclose=2  lazygit -ucd ~/.config/lazygit<CR>')
    vim.keymap.set(
      'n',
      '<c-t>',
      ':FloatermNew --autoclose=2  make && cd ~/Work/dopscopes/local/andretest/aa/dev && ~/Work/cli/doppler tui<CR>'
    )
    vim.keymap.set('n', '<c-q>', ':FloatermToggle<CR>')

    vim.keymap.set('t', '<c-q>', ':FloatermToggle<CR>')
    vim.keymap.set('t', '<c-q>', '<c-\\><c-n>:FloatermToggle<cr>')
    vim.keymap.set('t', '<c-]>', '<c-\\><c-n>')
    vim.keymap.set('t', '<c-o>', '<c-\\><c-n><c-o>')
    vim.keymap.set('t', '<a-[>', '<c-\\><c-n>gT')
    vim.keymap.set('t', '<a-]>', '<c-\\><c-n>gt')
    vim.keymap.set('t', '<a-k>', '<c-l>')
  end,
}
