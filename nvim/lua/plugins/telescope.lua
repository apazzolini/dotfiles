return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-telescope/telescope-fzy-native.nvim',
  },
  config = function()
    local actions = require('telescope.actions')
    local previewers = require('telescope.previewers')
    local andre_sorter = require('plugins.telescope.sorter')
    local select_multiple = require('plugins.telescope.select_multiple')
    require('plugins.telescope.mappings')

    local telescope_opts = {
      defaults = {
        path_display = {
          'filename_first',
        },
        set_env = {
          LESS = '',
          DELTA_PAGER = 'less',
        },
        vimgrep_arguments = {
          'rg',
          '--hidden',
          '--color=never',
          '--follow',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },

        prompt_prefix = '> ',
        sorting_strategy = 'ascending',
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
          mirror = true,
          horizontal = {
            preview_width = 0.5,
          },
        },

        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

        file_ignore_patterns = {
          '%.svg',
        },

        mappings = {
          i = {
            ['<c-j>'] = actions.move_selection_next,
            ['<c-k>'] = actions.move_selection_previous,
            ['<esc>'] = actions.close,
            ['<C-o>'] = actions.send_to_qflist + actions.open_qflist,
          },
        },
        file_sorter = function()
          return andre_sorter()
        end,
        generic_sorter = function()
          return andre_sorter()
        end,
      },
      pickers = {
        buffers = {
          prompt_title = '~ buffers ~',
          sort_lastused = true,
          mappings = {
            i = {
              ['<c-u>'] = require('telescope.actions').delete_buffer,
              ['<cr>'] = select_multiple,
            },
          },
          previewer = false,
          theme = 'dropdown',
          layout_config = { width = 120 },
        },
        find_files = {
          prompt_title = '~ files ~',
          follow = true,
          hidden = true,
          mappings = {
            i = {
              ['<cr>'] = select_multiple,
            },
          },
          previewer = false,
          theme = 'dropdown',
          layout_config = { width = 120 },
        },
        oldfiles = {
          prompt_title = '~ oldfiles ~',
          mappings = {
            i = {
              ['<cr>'] = select_multiple,
            },
          },
          previewer = false,
          theme = 'dropdown',
          layout_config = { width = 120 },
        },
        git_status = {
          prompt_title = '~ git changed ~',
          mappings = {
            i = {
              ['<cr>'] = select_multiple,
              ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<C-u>'] = actions.preview_scrolling_up,
            },
          },
          layout_strategy = 'horizontal',
          layout_config = {
            mirror = false,
          },
          previewer = previewers.new_termopen_previewer({
            get_command = function(entry)
              if entry.status == '??' or 'A ' then
                return { 'git', '-c', 'core.pager=delta', '-c', 'delta.paging=always', 'diff', entry.value }
              end

              return { 'git', '-c', 'core.pager=delta', '-c', 'delta.paging=always', 'diff', entry.value .. '^!' }
            end,
          }),
          -- previewer = false,
          -- previewer = previewers.new_buffer_previewer({
          --   define_preview = function(self, entry, status)
          --     local dir_name = vim.fn.substitute(vim.fn.getcwd(), '^.*/', '', '')
          --     vim.print(dir_name)
          --     vim.print(entry.value)
          --     local t = {}
          --     if entry.value == dir_name then
          --       local s = vim.fn.system('git status -s')
          --       for chunk in string.gmatch(s, '[^\n]+') do
          --         t[#t + 1] = chunk
          --       end
          --     else
          --       local s = vim.fn.system('git -c core.pager=delta -c delta.side-by-side=false diff ' .. entry.value)
          --       for chunk in string.gmatch(s, '[^\n]+') do
          --         t[#t + 1] = chunk
          --       end
          --     end
          --     vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, t)
          --   end,
          -- }),
          -- theme = 'dropdown',
          -- layout_config = { width = 120 },
        },
      },
    }

    -- require('telescope').load_extension('harpoon')
    require('telescope').setup(telescope_opts)
  end,
}
