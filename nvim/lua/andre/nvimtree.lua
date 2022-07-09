if not pcall(require, 'nvim-tree') then
  return
end

require('nvim-tree').setup({
  update_cwd = true,
  view = {
    width = 37,
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

vim.api.nvim_set_keymap('n', '<leader>go', '<cmd>NvimTreeToggle<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>NvimTreeFindFile<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>cd', '<cmd>cd %:p:h<cr>', {})
