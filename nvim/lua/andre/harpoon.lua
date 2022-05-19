if not pcall(require, 'harpoon') then
  return
end

require('harpoon').setup({
  menu = {
    width = 100,
  },
})

vim.api.nvim_set_keymap('n', '<leader>Hy', "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>HY', "<cmd>lua require('harpoon.mark').set_current_at(1)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>Hu', "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>HU', "<cmd>lua require('harpoon.mark').set_current_at(2)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>Hi', "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>HI', "<cmd>lua require('harpoon.mark').set_current_at(3)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>Ho', "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>HO', "<cmd>lua require('harpoon.mark').set_current_at(4)<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>Hp', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {})
