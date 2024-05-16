lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }, { name = 'buffer' }} })

map <buffer> <leader>r <Plug>(DBUI_ExecuteQuery)
