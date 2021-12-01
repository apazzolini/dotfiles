if not pcall(require, 'hop') then
  return
end

vim.api.nvim_set_keymap('n', ' ', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('x', ' ', "<cmd>lua require'hop'.hint_words()<cr>", {})

require('hop').setup()
