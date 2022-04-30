vim.g.nvim_tree_width = 40
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_special_files = {}
vim.g.nvim_tree_show_icons = {
  git = 0,
  folders = 1,
  files = 1,
}
vim.g.nvim_tree_icons = {
  default = ' ',
  folder = {
    default = '▸',
    open = '▾',
    empty = '▸',
    empty_open = '▾',
    symlink = '▸',
    symlink_open = '▾',
  },
}

require('nvim-tree').setup({
  update_cwd = true,
  view = {
    width = 37,
  },
  filters = {
    dotfiles = true,
    custom = { '.git', 'node_modules', 'bower_components', '.DS_Store', 'dist' },
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
})

vim.api.nvim_set_keymap('n', ',no', '<cmd>let g:nvim_tree_quit_on_open=!g:nvim_tree_quit_on_open<cr>', {})
vim.api.nvim_set_keymap('n', ',gg', '<cmd>NvimTreeFindFile<cr>', {})
vim.api.nvim_set_keymap('n', ',go', '<cmd>NvimTreeToggle<cr>', {})
vim.api.nvim_set_keymap('n', ',cd', '<cmd>cd %:p:h<cr>', {})
