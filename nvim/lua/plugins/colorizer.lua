return {
  'NvChad/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup({
      filetypes = {
        '*',
        cmp_docs = { always_update = true },
      },
      user_default_options = {
        mode = 'background',
        rgb_fn = true,
        names = false,
      },
    })
  end,
}
