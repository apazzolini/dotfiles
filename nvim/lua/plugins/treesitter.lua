-- :Inspect to show the highlight groups under the cursor
-- :InspectTree to show the parsed syntax tree ("TSPlayground")
-- :EditQuery to open the Live Query Editor (Nvim 0.10+)
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
    -- 'JoosepAlviste/nvim-ts-context-commentstring',
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'main',
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
    require('nvim-treesitter').setup({})
    require('nvim-treesitter-textobjects').setup({
      lookahead = true,
    })

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    local ensureInstalled = {
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
      'python',
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
    }
    local alreadyInstalled = require('nvim-treesitter.config').get_installed()
    local parsersToInstall = vim
      .iter(ensureInstalled)
      :filter(function(parser)
        return not vim.tbl_contains(alreadyInstalled, parser)
      end)
      :totable()
    require('nvim-treesitter').install(parsersToInstall)

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
          'if',
          'switch',
          'case',
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
    vim.keymap.set('n', '<leader>K', '<cmd>TSContext toggle<CR>')

    -- show current highlight, show highlight (this line here for grepping since I always forget this binding)
    vim.keymap.set('n', '<leader>SH', '<cmd>lua vim.print(vim.treesitter.get_captures_at_cursor())<CR>')

    vim.keymap.set({ 'x', 'o' }, 'af', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'if', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'ac', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@conditional.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'ic', function()
      require('nvim-treesitter-textobjects.select').select_textobject('@conditional.inner', 'textobjects')
    end)
  end,
}
