vim.g.mapleader = ','
vim.g.isNotes = vim.env.IS_NOTES == '1' or (vim.fn.argc() >= 1 and vim.fn.argv()[1]:match('index.md$') ~= nil)

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  change_detection = {
    notify = false,
  },
  ui = {
    border = 'rounded',
  },
})
