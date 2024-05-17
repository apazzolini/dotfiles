vim.opt_local.errorformat:append('%+A %#%f %#(%l\\,%c): %m,%C%m')
vim.opt_local.foldmethod = 'marker'
vim.opt_local.foldmarker = '#region,#endregion'

-- Test mappings
vim.keymap.set('n', '<leader>ot', "mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T", { buffer = 0 })
vim.keymap.set('n', '<leader>oa', "mT?test(<cr>cetest.only<esc>'T", { buffer = 0 })
vim.keymap.set('n', '<leader>ox', "mT:%s/test.only/test/ge<cr>'T", { buffer = 0 })
