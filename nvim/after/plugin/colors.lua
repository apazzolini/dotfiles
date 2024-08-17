vim.opt.background = vim.g.isNotes and 'light' or 'dark'
vim.opt.guifont = '"Operator Mono Book":h8'

-- You probably always want to set this in your vim file
vim.g.colors_name = 'wave'

-- By setting our module to nil, we clear lua's cache,
-- which means the require ahead will *always* occur.
--
-- This isn't strictly required but it can be a useful trick if you are
-- incrementally editing your config a lot and want to be sure your themes
-- changes are being picked up without restarting neovim.
--
-- Note if you're working in on your theme and have :Lushify'd the buffer,
-- your changes will be applied with our without the following line.
--
-- The performance impact of this call can be measured in the hundreds of
-- *nanoseconds* and such could be considered "production safe".
package.loaded['plugins.colors.wave'] = nil

-- include our theme file and pass it to lush to apply
require('lush')(require('plugins.colors.wave'))

vim.cmd.colorscheme('none')

vim.api.nvim_create_user_command('Lushify', function()
  require('lush').ify()
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = vim.api.nvim_create_augroup('lushify-shipwright', {}),
    buffer = 0,
    command = 'Shipwright ~/.dotfiles/nvim/colors/shipwright_build.lua',
  })
end, {})

vim.cmd([[
  command! Wave vsp ~/.dotfiles/nvim/lua/plugins/colors/wave.lua | Lushify
]])
