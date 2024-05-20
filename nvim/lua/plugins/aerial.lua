return {
  'stevearc/aerial.nvim',
  config = function()
    require('aerial').setup({
      on_attach = function(bufnr)
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
      end,
      backends = { 'treesitter', 'markdown', 'asciidoc', 'man' },
      highlight_on_jump = false,
      nav = {
        autojump = true,
        keymaps = {
          ['q'] = 'actions.close',
        },
      },
    })

    vim.keymap.set('n', 'gk', '<cmd>AerialNavToggle<CR>')
  end,
}
