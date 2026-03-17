return {
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('smart-splits').setup({
      -- log_level = 'trace',
      -- at_edge = 'stop',
      at_edge = function(ctx)
        if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
          local dir_map = { left = 'l', right = 'r', up = 'u', down = 'd' }
          vim.fn.system({ 'hyprctl', 'dispatch', 'movefocus', dir_map[ctx.direction] })
        end
      end,
    })
    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
    vim.keymap.set('n', '<C-left>', require('smart-splits').resize_left)
    vim.keymap.set('n', '<C-down>', require('smart-splits').resize_down)
    vim.keymap.set('n', '<C-up>', require('smart-splits').resize_up)
    vim.keymap.set('n', '<C-right>', require('smart-splits').resize_right)
  end,
}
