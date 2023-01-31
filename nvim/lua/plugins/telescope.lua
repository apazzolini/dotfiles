return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-telescope/telescope-fzy-native.nvim',
  },
  config = function()
    local actions = require('telescope.actions')
    local andre_sorter = require('andre.telescope.sorter')
    local select_multiple = require('andre.telescope.select_multiple')
    require('andre.telescope.mappings')

    local telescope_opts = {
      defaults = {
        vimgrep_arguments = {
          'rg',
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
            },
          },
          layout_config = { width = 140, height = 0.8 },
        },
      },
      -- extensions = {
      --   fzy_native = {
      --     override_generic_sorter = false,
      --     override_file_sorter = true,
      --   },
      -- },
    }

    require('telescope').setup(telescope_opts)
  end,
}
