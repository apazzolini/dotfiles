-- Convenience mappings
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'H', '0')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', ',<c-d>', '<c-d>')
vim.keymap.set('n', ',<c-u>', '<c-u>')
vim.keymap.set('n', '<c-d>', function()
  vim.cmd([[
    set lazyredraw
    execute "normal " .  "20,\<c-d>zz"
    set nolazyredraw
    redraw
  ]])
end)
vim.keymap.set('n', '<c-u>', function()
  vim.cmd([[
    set lazyredraw
    execute "normal " .  "20,\<c-u>zz"
    set nolazyredraw
    redraw
  ]])
end)
vim.keymap.set('n', '<c-e>', '3<c-e>')
vim.keymap.set('n', '<c-y>', '3<c-y>')
vim.keymap.set('n', '0', '0^')
vim.keymap.set('n', '^', '0')
vim.keymap.set('n', '<leader><leader>', '<c-^>')
vim.keymap.set('n', '<leader>y', '"*y')
vim.keymap.set('v', '<leader>y', '"*y')
vim.keymap.set('n', '<cr>', ':noh<cr><cr>', { silent = true })
vim.keymap.set('n', 'J', 'mzJ`z')

vim.keymap.set('x', 'L', 'g_')
vim.keymap.set('x', '<leader>p', '"_dP')

vim.keymap.set('i', '<c-l>', '<space>=><space>')

vim.keymap.set('c', '<c-k>', '<c-p>')
vim.keymap.set('c', '<c-j>', '<c-n>')
vim.keymap.set('c', '<up>', '<c-p>')
vim.keymap.set('c', '<down>', '<c-n>')

-- Disable mouse pasting
vim.keymap.set('n', '<MiddleMouse>', '<Nop>')
vim.keymap.set('i', '<MiddleMouse>', '<Nop>')
vim.keymap.set('n', '<2-MiddleMouse>', '<Nop>')
vim.keymap.set('i', '<2-MiddleMouse>', '<Nop>')

-- Set line to middle of screen on jump operations
vim.keymap.set('n', '<c-o>', '<c-o>zz')
vim.keymap.set('n', '<c-i>', '<c-i>zz')
vim.keymap.set('n', '<c-t>', '<c-t>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Break undo sequence at punctuation marks
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', '!', '!<c-g>u')
vim.keymap.set('i', '?', '?<c-g>u')

-- Move lines up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Increment / decrement numbers
vim.keymap.set('n', '+', '<C-a>')
vim.keymap.set('n', '-', '<C-x>')
vim.keymap.set('x', '+', 'g<C-a>')
vim.keymap.set('x', '-', 'g<C-x>')

-- Split / tab mappings
vim.keymap.set('n', '<leader>nt', ':tabnew<cr>')
vim.keymap.set('n', 'c<C-j>', ':bel new<cr>')
vim.keymap.set('n', 'c<C-k>', ':abo new<cr>')
vim.keymap.set('n', 'c<C-h>', ':lefta vnew<cr>')
vim.keymap.set('n', 'c<C-l>', ':rightb vnew<cr>')
vim.keymap.set('n', '<m-[>', 'gT')
vim.keymap.set('n', '<m-]>', 'gt')

-- Window zooming
vim.keymap.set('n', '<leader>we', ':set winheight=999<cr>')
vim.keymap.set('n', '<leader>wd', ':set winheight=10<cr><c-w>=<cr>')

-- Comments
vim.keymap.set('n', '<leader>ct', 'gcc', { remap = true })
vim.keymap.set('x', '<leader>ct', 'gc', { remap = true })
