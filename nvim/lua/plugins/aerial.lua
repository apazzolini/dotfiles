return {
  'stevearc/aerial.nvim',
  config = function()
    require('aerial').setup({
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      -- on_attach = function(bufnr)
      --   -- Jump forwards/backwards with '{' and '}'
      --   vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
      --   vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
      -- end,
      -- backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
      backends = { 'treesitter', 'markdown', 'asciidoc', 'man' },
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
