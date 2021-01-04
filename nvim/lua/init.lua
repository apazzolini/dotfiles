require('colorizer').setup()

require'nvim-treesitter.configs'.setup {
  indent = {
    enable = true,
  },

  highlight = {
    enable = true,
    custom_captures = {
      ["classname"] = "ClassName",
      ["reactHook"] = "ReactHook",
      ["attribute.jsx"] = "jsxAttribute",
    },
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },
}
