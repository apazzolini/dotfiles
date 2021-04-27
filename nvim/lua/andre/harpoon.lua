vim.api.nvim_set_keymap('n', ',Pu', "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", {})
vim.api.nvim_set_keymap('n', ',Pi', "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", {})
vim.api.nvim_set_keymap('n', ',Po', "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", {})
vim.api.nvim_set_keymap('n', ',PP', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {})
vim.api.nvim_set_keymap('n', ',Pa', "<cmd>lua require('harpoon.mark').add_file()<cr>", {})