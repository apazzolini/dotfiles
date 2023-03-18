local yank_path = function(state) end

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
    })

    vim.keymap.set('n', '<leader>go', '<cmd>Neotree toggle current reveal_force_cwd dir=%:p:h<cr>')
    vim.keymap.set('n', '<leader>gg', '<cmd>Neotree reveal<cr>')
    vim.keymap.set('n', '<leader>ge', '<cmd>Neotree buffers<cr>')
  end,
}
