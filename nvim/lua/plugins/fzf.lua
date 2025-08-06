return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  -- opts = {},
  config = function()
    -- vim.print('Setting up')
    require('fzf-lua').setup({
      fzf_opts = {
        ['--cycle'] = true,
      },

      winopts = {
        preview = {
          layout = 'vertical',
          vertical = 'down:65%',
        },
      },

      keymap = {
        builtin = {
          ['<esc>'] = 'hide',
          ['<c-e>'] = 'preview-page-up',
          ['<c-y>'] = 'preview-page-down',
        },
        fzf = {
          ['ctrl-q'] = 'select-all+accept',
        },
      },

      defaults = {
        -- formatter = 'path.filename_first',
        -- multiline = 0,
      },

      grep = {
        rg_glob = true, -- enable glob parsing by default to all grep providers? (default:false)
        glob_flag = '--iglob', -- for case sensitive globs use '--glob'
        glob_separator = '%s%s', -- query separator pattern (lua): '  '
        RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
      },

      files = {
        previewer = false,
        git_icons = false,
        file_icons = false,
        winopts = { height = 25, width = 120 },
        cmd = 'rg --files --hidden --ignore --glob "!.git" --sortr=modified',
        RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
        fzf_opts = {
          ['--scheme'] = 'path',
          ['--tiebreak'] = 'index',
        },
      },
    })

    vim.keymap.set('n', '<leader>e', function()
      require('fzf-lua').files()
    end)

    vim.keymap.set('n', '<leader>E', function()
      require('fzf-lua').files({ cwd = vim.fn.expand('%:p:h') })
    end)

    vim.keymap.set('n', '<leader>a', function()
      require('fzf-lua').live_grep()
    end)

    vim.keymap.set('n', '<leader>W', function()
      require('fzf-lua').grep_cword()
    end)

    vim.keymap.set('n', '<leader>/', function()
      require('fzf-lua').lgrep_curbuf()
    end)

    vim.keymap.set('n', '<leader>sh', function()
      require('fzf-lua').helptags()
    end)

    vim.keymap.set('n', '<leader>sk', function()
      require('fzf-lua').keymaps()
    end)

    vim.keymap.set('n', '<leader>sb', function()
      require('fzf-lua').builtin()
    end)
  end,
}
