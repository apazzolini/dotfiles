vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_width = 40
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_disable_window_picker = 1
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
  nvim_tree_hide_dotfiles = true,
  nvim_tree_ignore = { '.git', 'node_modules', 'bower_components', '.DS_Store', 'dist' },
  view = {
    width = 37,
    auto_resize = true,
  },
})

vim.api.nvim_set_keymap('n', ',no', '<cmd>let g:nvim_tree_quit_on_open=!g:nvim_tree_quit_on_open<cr>', {})
vim.api.nvim_set_keymap('n', ',gg', '<cmd>NvimTreeFindFile<cr>', {})
vim.api.nvim_set_keymap('n', ',go', '<cmd>NvimTreeToggle<cr>', {})
vim.api.nvim_set_keymap('n', ',cd', '<cmd>cd %:p:h<cr>', {})
