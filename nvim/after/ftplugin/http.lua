local rest = require('rest-nvim')

vim.keymap.set('n', '<leader>r', function()
  rest.run()
end, { buffer = true })

vim.keymap.set('n', '<leader>R', function()
  rest.run(true)
end, { buffer = true })
