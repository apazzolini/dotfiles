-- :Inspect to show the highlight groups under the cursor
-- :InspectTree to show the parsed syntax tree ("TSPlayground")
-- :EditQuery to open the Live Query Editor (Nvim 0.10+)
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'windwp/nvim-ts-autotag',
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      dependencies = {
        'kana/vim-textobj-user',
        'kana/vim-textobj-line',
        'kana/vim-textobj-entire',
      },
    },
    -- {
    --   'yioneko/nvim-yati',
    -- },
  },
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'astro',
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
        'http',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'lua',
        'make',
        'markdown',
        'regex',
        'scss',
        'sql',
        'svelte',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
        'zig',
      },
      indent = {
        enable = true,
        -- disable = { 'javascript', 'typescript', 'jsx', 'tsx' },
      },
      yati = {
        enable = false,
        -- Disable by languages, see `Supported languages`
        disable = { 'python', 'lua', 'html', 'json', 'css' },

        -- Whether to enable lazy mode (recommend to enable this if bad indent happens frequently)
        default_lazy = true,

        -- Determine the fallback method used when we cannot calculate indent by tree-sitter
        --   "auto": fallback to vim auto indent
        --   "asis": use current indent as-is
        --   "cindent": see `:h cindent()`
        -- Or a custom function return the final indent result.
        default_fallback = 'auto',
      },
      highlight = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@conditional.outer',
            ['ic'] = '@conditional.inner',
          },
        },
      },
      autotag = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = '<Tab>',
          node_decremental = '<BS>',
        },
      },
    })

    require('treesitter-context').setup({
      enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      patterns = {
        -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
        -- For all filetypes
        -- Note that setting an entry here replaces all other patterns for this entry.
        -- By setting the 'default' entry below, you can control which nodes you want to
        -- appear in the context window.
        default = {
          'class',
          'function',
          'method',
          -- 'for', -- These won't appear in the context
          -- 'while',
          -- 'if',
          -- 'switch',
          -- 'case',
        },
        -- Example for a specific filetype.
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        --   rust = {
        --       'impl_item',
        --   },
      },
      exact_patterns = {
        -- Example for a specific filetype with Lua patterns
        -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
        -- exactly match "impl_item" only)
        -- rust = true,
      },
      -- [!] The options below are exposed but shouldn't require your attention,
      --     you can safely ignore them.
      zindex = 20, -- The Z-index of the context window
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
    })

    vim.keymap.set('n', '<leader>SH', '<cmd>lua vim.print(vim.treesitter.get_captures_at_cursor())<CR>')
    vim.keymap.set('n', '<leader>K', '<cmd>TSContextToggle<CR>')
  end,
}
