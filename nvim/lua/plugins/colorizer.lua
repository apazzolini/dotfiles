return {
  'apazzolini/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup(nil, { mode = 'background', rgb_fn = true })
  end,
}
