return {
  'phaazon/hop.nvim',
  config = function()
    local hop = require('hop')
    hop.setup()
    vim.keymap.set('n', ' ', hop.hint_words)
  end,
}
