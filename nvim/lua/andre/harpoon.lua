require("harpoon").setup({
  menu = {
    width = 100,
  }
})

vim.api.nvim_set_keymap('n', ',Hy', "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", {})
vim.api.nvim_set_keymap('n', ',HY', "<cmd>lua require('harpoon.mark').set_current_at(1)<cr>", {})
vim.api.nvim_set_keymap('n', ',Hu', "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", {})
vim.api.nvim_set_keymap('n', ',HU', "<cmd>lua require('harpoon.mark').set_current_at(2)<cr>", {})
vim.api.nvim_set_keymap('n', ',Hi', "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", {})
vim.api.nvim_set_keymap('n', ',HI', "<cmd>lua require('harpoon.mark').set_current_at(3)<cr>", {})
vim.api.nvim_set_keymap('n', ',Ho', "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", {})
vim.api.nvim_set_keymap('n', ',HO', "<cmd>lua require('harpoon.mark').set_current_at(4)<cr>", {})
vim.api.nvim_set_keymap('n', ',Hp', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {})
