return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    'tpope/vim-dadbod',
  },
  config = function()
    vim.cmd([[ let g:db_ui_save_location = "~/Work/db" ]])
  end,
}
