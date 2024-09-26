vim.opt_local.colorcolumn = ''
vim.opt_local.winheight = 10
vim.opt_local.spell = false

vim.keymap.set('n', 'q', '<c-w>q', { silent = true, buffer = 0 })
vim.keymap.set('n', 'dd', ':.Reject<cr>', { silent = true, buffer = 0 })
vim.keymap.set('n', 'D', ':.Reject<cr>', { silent = true, buffer = 0 })
vim.keymap.set('x', 'd', ":'<,'>Reject<cr>", { silent = true, buffer = 0 })
vim.keymap.set('n', '<s-j>', 'j<cr><c-w><c-w>', { silent = true, buffer = 0 })
vim.keymap.set('n', '<s-k>', 'k<cr><c-w><c-w>', { silent = true, buffer = 0 })
vim.keymap.set('n', '<cr>', '<cr>', { silent = true, buffer = 0 })
