return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v2.x',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

    require('neo-tree').setup({
      close_if_last_window = true,
      popup_border_style = 'rounded',
      enable_git_status = false,
      enable_diagnostics = false,
      sort_case_insensitive = false,
      default_component_configs = {
        icon = {
          folder_closed = '▸',
          folder_open = '▾',
          folder_empty = 'ﰊ',
          default = ' ',
        },
        modified = {
          symbol = '',
        },
      },
      window = {
        width = 40,
        mappings = {
          ['o'] = 'open',
        },
      },
      filesystem = {
        cwd_target = {
          current = 'none',
        },
        filtered_items = {
          hide_by_name = {
            'node_modules',
            'bower_components',
            'dist',
            '.git',
            'tsconfig.json',
            'bun.lockb',
          },
          never_show = {
            '.DS_Store',
          },
        },
        window = {
          mappings = {
            ['YF'] = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('*', node.name)
            end,
            ['YP'] = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('*', node.path)
            end,
            ['YR'] = function(state)
              local node = state.tree:get_node()
              local cwd = vim.fn.getcwd()
              if node.path:find('^' .. cwd) ~= nil then
                vim.fn.setreg('*', string.sub(node.path, #cwd + 2))
              else
                print('File not a child of cwd')
              end
            end,
          },
        },
      },
      buffers = {
        window = {
          mappings = {
            ['d'] = 'buffer_delete',
          },
        },
      },
      -- event_handlers = {
      --   {
      --     event = 'file_opened',
      --     handler = function(_)
      --       require('neo-tree.command').execute({ action = 'close' })
      --     end,
      --     id = 'optional unique id, only meaningful if you want to unsubscribe later',
      --   },
      -- },
    })

    vim.keymap.set('n', '<leader>gG', '<cmd>Neotree reveal<cr>')
    vim.keymap.set('n', '-', '<cmd>Neotree reveal current<cr>')
    vim.keymap.set('n', '_', '<cmd>Neotree git_status current<cr>')
    vim.keymap.set('n', '<leader>ge', '<cmd>Neotree buffers current<cr>')
  end,
}
