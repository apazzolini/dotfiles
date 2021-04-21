if not pcall(require, 'hop') then
  return
end

vim.api.nvim_set_keymap('n', ' ', "<cmd>lua require'hop'.hint_words()<cr>", {})
