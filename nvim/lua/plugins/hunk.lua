return {
  'julienvincent/hunk.nvim',
  cmd = { 'DiffEditor' },
  config = function()
    local hunk = require('hunk')

    -- track all the lines of leaf nodes so we don't have to recompute them on each key press
    local jumpable_lines
    local function set_jumpabe_lines(context)
      jumpable_lines = {}

      local i = 1
      local n, _, _ = context.tree:get_node(i)
      while n do
        if not n:has_children() then
          table.insert(jumpable_lines, i)
        end
        i = i + 1
        n, _, _ = context.tree:get_node(i)
      end
    end

    hunk.setup({
      keys = {
        global = {
          quit = { 'q' },
          accept = { '<leader><Cr>' },
          focus_tree = { '<leader>e' },
        },

        tree = {
          expand_node = { 'l', '<Right>' },
          collapse_node = { 'h', '<Left>' },

          open_file = { '<Cr>' },

          toggle_file = { 'a' },
        },

        diff = {
          toggle_hunk = { 'A' },
          toggle_line = { 'a' },
          -- This is like toggle_line but it will also toggle the line on the other
          -- 'side' of the diff.
          toggle_line_pair = { 's' },

          prev_hunk = { '[h' },
          next_hunk = { ']h' },

          -- Jump between the left and right diff view
          toggle_focus = { '<Tab>' },
        },
      },

      ui = {
        tree = {
          -- Mode can either be `nested` or `flat`

          mode = 'nested',
          width = 35,
        },
        --- Can be either `vertical` or `horizontal`
        layout = 'vertical',
      },

      -- icons = {
      --   selected = '󰡖',
      --   deselected = '',
      --
      --   partially_selected = '󰛲',
      --
      --   folder_open = '',
      --   folder_closed = '',
      -- },

      -- Called right after each window and buffer are created.
      hooks = {
        ---@param context { buf: number, win: number }
        on_tree_mount = function(context)
          vim.api.nvim_set_option_value('spell', false, { win = context.win })

          vim.keymap.set('n', 'j', function()
            -- unfortunately we have to recompute every time because folding ruins these computed values
            set_jumpabe_lines(context)
            local row = vim.api.nvim_win_get_cursor(0)[1]
            if row < jumpable_lines[1] then
              vim.api.nvim_win_set_cursor(0, { jumpable_lines[1], 0 })
              return
            end
            for idx = #jumpable_lines, 1, -1 do
              if jumpable_lines[idx] <= row then
                if jumpable_lines[idx + 1] then
                  vim.api.nvim_win_set_cursor(0, { jumpable_lines[idx + 1], 0 })
                end

                return
              end
            end
          end, { buffer = context.buf })

          vim.keymap.set('n', 'k', function()
            set_jumpabe_lines(context)
            local row = vim.api.nvim_win_get_cursor(0)[1]
            if row > jumpable_lines[#jumpable_lines] then
              vim.api.nvim_win_set_cursor(0, { jumpable_lines[#jumpable_lines], 0 })
              return
            end
            for idx, node_row in ipairs(jumpable_lines) do
              if node_row >= row then
                if jumpable_lines[idx - 1] then
                  vim.api.nvim_win_set_cursor(0, { jumpable_lines[idx - 1], 0 })
                end
                return
              end
            end
          end, { buffer = context.buf })
        end,

        ---@param _context { buf: number, win: number }
        on_diff_mount = function(_context) end,
      },
    })
  end,
}
