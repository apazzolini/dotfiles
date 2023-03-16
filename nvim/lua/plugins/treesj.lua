return {
  'Wansmer/treesj',
  config = function()
    require('treesj').setup({
      use_default_keymaps = false,
      check_syntax_error = true,
      max_join_length = 130,
      cursor_behavior = 'hold',
      notify = true,
      -- langs = langs,
      dot_repeat = true,
    })

    vim.keymap.set('n', '<leader>tb', require('treesj').toggle)
  end,
}
