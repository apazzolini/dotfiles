vim.cmd([[wincmd L]])
vim.cmd([[vertical resize 90]])
vim.keymap.set('n', 'q', '<c-w>q', { silent = true, buffer = 0 })
vim.keymap.set('n', 'gd', '<c-]>', { silent = true, buffer = 0 })
