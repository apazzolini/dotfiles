return {
  'ThePrimeagen/harpoon',
  config = function()
    require('harpoon').setup({
      menu = {
        width = 100,
      },
    })

    local ui = require('harpoon.ui')
    local mark = require('harpoon.mark')

    vim.keymap.set('n', '<leader>w', function()
      ui.toggle_quick_menu()
    end)
    vim.keymap.set('n', '<leader>Wa', function()
      mark.add_file()
    end)
    vim.keymap.set('n', '<leader>Hp', function()
      ui.toggle_quick_menu()
    end)
    vim.keymap.set('n', '<leader>Hy', function()
      ui.nav_file(1)
    end)
    vim.keymap.set('n', '<leader>HY', function()
      mark.set_current_at(1)
    end)
    vim.keymap.set('n', '<leader>Hu', function()
      ui.nav_file(2)
    end)
    vim.keymap.set('n', '<leader>HU', function()
      mark.set_current_at(2)
    end)
    vim.keymap.set('n', '<leader>Hi', function()
      ui.nav_file(3)
    end)
    vim.keymap.set('n', '<leader>HI', function()
      mark.set_current_at(3)
    end)
    vim.keymap.set('n', '<leader>Ho', function()
      ui.nav_file(4)
    end)
    vim.keymap.set('n', '<leader>HO', function()
      mark.set_current_at(4)
    end)
  end,
}
