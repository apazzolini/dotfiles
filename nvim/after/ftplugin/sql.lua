require('cmp').setup.buffer({ sources = { { name = 'vim-dadbod-completion' }, { name = 'buffer' } } })

vim.keymap.set('n', '<leader>r', '<Plug>(DBUI_ExecuteQuery)', { silent = true, buffer = 0 })
