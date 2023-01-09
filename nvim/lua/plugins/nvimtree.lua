return {
  'kyazdani42/nvim-tree.lua',
  commit = '21fadc1f38e4c6b6a4ae3ebf5ac922e2390175ca',
  config = function()
    require('nvim-tree').setup({
      update_cwd = true,
      view = {
        width = 60,
      },
      filters = {
        dotfiles = true,
        -- custom = { '\\.git', 'node_modules', 'bower_components', '.DS_Store', 'dist' },
      },
      actions = {
        open_file = {
          resize_window = true,
          quit_on_open = false,
          window_picker = {
            enable = false,
          },
        },
      },
      renderer = {
        special_files = {},
        highlight_opened_files = 'icon',
        icons = {
          show = {
            file = true,
            folder = true,
            git = false,
            folder_arrow = false,
          },
          glyphs = {
            default = ' ',
            folder = {
              default = '▸',
              open = '▾',
              empty = '▸',
              empty_open = '▾',
              symlink = '▸',
              symlink_open = '▾',
            },
          },
        },
      },
    })

    vim.keymap.set('n', '<leader>go', '<cmd>NvimTreeToggle<cr>')
    vim.keymap.set('n', '<leader>gg', '<cmd>NvimTreeFindFile<cr>')
    vim.keymap.set('n', '<leader>cd', '<cmd>cd %:p:h<cr>')
  end,
}
