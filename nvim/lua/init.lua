require 'colorizer'.setup({
  '*';
}, { mode = 'foreground' })

require'nvim-treesitter.configs'.setup {
  indent = {
    enable = false,
  },

  highlight = {
    enable = true,
    custom_captures = {
      ["className"] = "TS_C_ClassName",
      ["reactHook"] = "TS_C_ReactHook",
      ["jsxAttribute"] = "TS_C_JsxAttribute",
    },
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },
}

-- require'lspconfig'.tsserver.setup{}
