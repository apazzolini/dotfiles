require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",

  indent = {
    enable = true,
  },

  highlight = {
    enable = true,
    custom_captures = {
      ["className"] = "TS_C_ClassName",
      ["reactHook"] = "TS_C_ReactHook",
      ["jsxAttribute"] = "TS_C_JsxAttribute",
      ["function.call"] = "TS_C_FunctionCall",
    },
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
      },
    }
  },

  context_commentstring = {
    enable = true
  }
}
