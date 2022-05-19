require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'c',
    'cmake',
    'comment',
    'css',
    'dockerfile',
    'elixir',
    'eex',
    'go',
    'graphql',
    'html',
    'javascript',
    'jsdoc',
    'json',
    'json5',
    'lua',
    'make',
    'markdown',
    'regex',
    'scss',
    'svelte',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },

  indent = {
    enable = false,
  },

  highlight = {
    enable = true,
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
  },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@conditional.outer',
        ['ic'] = '@conditional.inner',
      },
    },
  },

  context_commentstring = {
    enable = true,
  },

  autotag = {
    enable = true,
  },
})

require('nvim-treesitter.highlight').set_custom_captures({
  ['className'] = 'TS_C_ClassName',
  ['reactHook'] = 'TS_C_ReactHook',
  ['jsxAttribute'] = 'TS_C_JsxAttribute',
  ['function.call'] = 'TS_C_FunctionCall',
})

-- local parsers = require('nvim-treesitter.parsers')
-- local configs = parsers.get_parser_configs()
-- local ft_str = table.concat(
--   vim.tbl_map(function(ft)
--     return configs[ft].filetype or ft
--   end, parsers.available_parsers()),
--   ','
-- )
-- vim.cmd('autocmd Filetype ' .. ft_str .. ' setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()')
