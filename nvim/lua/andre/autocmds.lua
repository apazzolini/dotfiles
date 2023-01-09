-- Show cursor line only in active window
vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, 'auto-cursorline')
    if ok and cl then
      vim.wo.cursorline = true
      vim.api.nvim_win_del_var(0, 'auto-cursorline')
    end
  end,
})
vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
  callback = function()
    local cl = vim.wo.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, 'auto-cursorline', cl)
      vim.wo.cursorline = false
    end
  end,
})

vim.api.nvim_create_autocmd({ 'VimResized' }, { command = ':wincmd =' })

vim.api.nvim_create_autocmd({ 'BufWritePre' }, { command = [[%s/\s\+$//e]] })
vim.api.nvim_create_autocmd({ 'BufWritePre' }, { command = [[%s#\($\n\s*\)\+\%$##e]] })

if vim.fn.executable('stylua') == 1 then
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*.lua',
    callback = function()
      require('andre.stylua').format()
    end,
  })
end
