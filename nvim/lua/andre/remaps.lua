-- Convenience mappings
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'H', '0')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<c-d>', '20<c-d>zz')
vim.keymap.set('n', '<c-u>', '20<c-u>zz')
vim.keymap.set('n', '<c-e>', '3<c-e>')
vim.keymap.set('n', '<c-y>', '3<c-y>')
vim.keymap.set('n', '0', '0^')
vim.keymap.set('n', '^', '0')
vim.keymap.set('n', 'gx', ':tabclose<CR>')
vim.keymap.set('n', 'gq', ':q<cr>')
vim.keymap.set('n', '<leader><leader>', '<c-^>')
vim.keymap.set('i', '<c-l>', '<space>=><space>')
vim.keymap.set('x', 'L', 'g_')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('x', '<leader>p', '"_dP')
vim.keymap.set('c', '<c-k>', '<up>')
vim.keymap.set('c', '<c-j>', '<down>')
vim.keymap.set('n', '<cr>', ':noh<cr><cr>', { silent = true })

-- Disable mouse pasting
vim.keymap.set('n', '<MiddleMouse>', '<Nop>')
vim.keymap.set('i', '<MiddleMouse>', '<Nop>')
vim.keymap.set('n', '<2-MiddleMouse>', '<Nop>')
vim.keymap.set('i', '<2-MiddleMouse>', '<Nop>')

-- Set line to middle of screen on jump operations
vim.keymap.set('n', '<c-o>', '<c-o>zz')
vim.keymap.set('n', '<c-i>', '<c-i>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'J', 'mzJ`z')

-- Break undo sequence at punctuation marks
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', '!', '!<c-g>u')
vim.keymap.set('i', '?', '?<c-g>u')

-- Move lines up and down
vim.keymap.set('v', 'J', ':m >+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m <-2<CR>gv=gv')

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
vim.keymap.set('n', '<a-[>', 'gT')
vim.keymap.set('n', '<a-]>', 'gt')
-- These get overridden by tmux-navigator when in tmux
vim.keymap.set('n', '<c-h>', '<c-w>')
vim.keymap.set('n', '<c-j>', '<c-w>')
vim.keymap.set('n', '<c-k>', '<c-w>')
vim.keymap.set('n', '<c-l>', '<c-w>')

-- Window zooming
vim.keymap.set('n', '<leader>we', ':set winheight=999<cr>')
vim.keymap.set('n', '<leader>wd', ':set winheight=10<cr><c-w>=<cr>')