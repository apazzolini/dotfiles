return {
  'tpope/vim-dadbod',
  'kristijanhusak/vim-dadbod-completion',
  {
    'kristijanhusak/vim-dadbod-ui',
    config = function()
      vim.cmd([[ let g:db_ui_save_location = "~/Work/db" ]])
    end,
  },
}

-- Maybe replace this with dbee?
