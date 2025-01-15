return {
  'stevearc/oil.nvim',
  enabled = true,
  config = function()
    require('oil').setup({
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
      -- (:help prompt_save_on_select_new_entry)
      prompt_save_on_select_new_entry = true,
      -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
      -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
      -- Additionally, if it is a string that matches "actions.<name>",
      -- it will use the mapping at require("oil.actions").<name>
      -- Set to `false` to remove a keymap
      -- See :help oil-actions for a list of all available actions
      keymaps = {
        --   ['g?'] = { 'actions.show_help', mode = 'n' },
        --   ['<CR>'] = 'actions.select',
        --   ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        --   ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
        --   ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        --   ['<C-p>'] = 'actions.preview',
        ['q'] = { 'actions.close', mode = 'n' },
        --   ['<C-l>'] = 'actions.refresh',
        --   ['-'] = { 'actions.parent', mode = 'n' },
        ['<BS>'] = { 'actions.parent', mode = 'n' },
        --   ['_'] = { 'actions.open_cwd', mode = 'n' },
        --   ['`'] = { 'actions.cd', mode = 'n' },
        --   ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
        --   ['gs'] = { 'actions.change_sort', mode = 'n' },
        --   ['gx'] = 'actions.open_external',
        --   ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        --   ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
      },
      -- Set to false to disable all of the above keymaps
      -- use_default_keymaps = true,
      -- Extra arguments to pass to SCP when moving/copying files over SSH
      float = {
        -- Padding around the floating window
        padding = 2,
        -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        max_width = 0,
        max_height = 0,
        border = 'rounded',
        win_options = {
          winblend = 0,
        },
        -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
        get_win_title = nil,
        -- preview_split: Split direction: "auto", "left", "right", "above", "below".
        preview_split = 'auto',
        -- This is the config that will be passed to nvim_open_win.
        -- Change values here to customize the layout
        override = function(conf)
          return conf
        end,
      },
    })
    vim.keymap.set('n', '<leader>gG', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
  end,
}
