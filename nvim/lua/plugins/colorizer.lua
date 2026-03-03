return {
  'catgoose/nvim-colorizer.lua',
  config = function()
    vim.opt.termguicolors = true

    require('colorizer').setup({
      filetypes = {
        '*',
        cmp_docs = { always_update = true },
        cmp_menu = { always_update = true },
      },
      user_default_options = {
        mode = 'background',
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        rgb_fn = true,
        names = false,
      },
    })
  end,
}
