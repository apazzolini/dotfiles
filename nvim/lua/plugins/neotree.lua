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
      },
    })

    vim.keymap.set('n', '<leader>go', '<cmd>Neotree toggle current reveal_force_cwd dir=%:p:h<cr>')
    vim.keymap.set('n', '<leader>gg', '<cmd>Neotree reveal<cr>')
    vim.keymap.set('n', '<leader>ge', '<cmd>Neotree buffers<cr>')
  end,
}
