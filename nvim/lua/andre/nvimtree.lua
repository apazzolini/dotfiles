if not pcall(require, 'nvim-tree') then
  return
end

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
      quit_on_open = true,
      window_picker = {
        enable = false,
      },
    },
  },
})

vim.api.nvim_set_keymap('n', '<leader>no', '<cmd>let g:nvim_tree_quit_on_open=!g:nvim_tree_quit_on_open<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>NvimTreeFindFile<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>go', '<cmd>NvimTreeToggle<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>cd', '<cmd>cd %:p:h<cr>', {})
