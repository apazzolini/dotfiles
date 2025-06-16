local kulala = require('kulala')

vim.keymap.set('n', '<leader>r', function()
  kulala.run()
end, { buffer = true })
--
-- vim.keymap.set('n', '<leader>R', function()
--   rest.run(true)
-- end, { buffer = true })
