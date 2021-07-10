vim.api.nvim_set_keymap('n', ',Pj', "<cmd>lua require('harpoon.ui').nav_next()<cr>", {})
vim.api.nvim_set_keymap('n', ',Pk', "<cmd>lua require('harpoon.ui').nav_prev()<cr>", {})
vim.api.nvim_set_keymap('n', ',PP', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {})
vim.api.nvim_set_keymap('n', ',Pa', "<cmd>lua require('harpoon.mark').add_file()<cr>", {})
vim.api.nvim_set_keymap('n', ',Pe', "<cmd>lua require('harpoon.term').gotoTerminal(1)<cr>", {})
