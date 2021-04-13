if not pcall(require, 'telescope') then
  return
end

require('andre.telescope.mappings')

local action_state = require('telescope.actions.state')
local action_set = require('telescope.actions.set')
local actions = require('telescope.actions')

local select_multiple = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = current_picker:get_multi_selection()

  if table.getn(multi_selections) > 0 then
    actions.send_selected_to_qflist(prompt_bufnr)
    actions.open_qflist()
  else
    action_set.select(prompt_bufnr, "default")
  end
end

require('telescope').load_extension('fzy_native')
require('telescope').setup {
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
        color_devicons = true,
        prompt_position = 'top',
        sorting_strategy = 'ascending',

        layout_strategy = 'horizontal',
        layout_defaults = {
          horizontal = {
            preview_width = 0.60,
          },
          vertical = {
            mirror = true,
            preview_height = 0.60,
          },
        },

        file_sorter = require('telescope.sorters').get_fzy_sorter,
        file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

        file_ignore_patterns = {
          "git/*",
          "*.key",
          "**/node_modules/**"
        },

        mappings = {
            i = {
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
              ["<esc>"] = actions.close,
              ["<cr>"] = select_multiple,
              ["<bs>"] = '<bs>',
              ["<C-o>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}

local M = {}

function M.edit_dotfiles()
  require('telescope.builtin').find_files {
    prompt_title = "~ dotfiles ~",
    shorten_path = false,
    cwd = "~/.dotfiles",
  }
end

function M.live_grep()
  require('telescope.builtin').live_grep {
    prompt_title = "~ live grep ~",
    layout_config = {
      preview_width = 0.5,
    },
 }
end

function M.buffers()
  require('telescope.builtin').buffers {
    prompt_title = "~ buffers ~",
    shorten_path = false,
    attach_mappings = function(prompt_bufnr, map)
      local delete_buf = function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selections = current_picker:get_multi_selection()

        if next(multi_selections) == nil then
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.api.nvim_buf_delete(selection.bufnr, {force = true})
        else
          actions.close(prompt_bufnr)
          for _, selection in ipairs(multi_selections) do
            vim.api.nvim_buf_delete(selection.bufnr, {force = true})
          end
        end
      end

      map('i', '<c-u>', delete_buf)

      return true
    end
  }
end

function M.find_files()
  require('telescope.builtin').find_files({
    prompt_title = "~ files ~",
    follow = true,
  })
end

function M.current_dir_files()
  require('telescope.builtin').find_files({
    prompt_title = string.format("~ files in [%s] ~", vim.fn.expand("%:h")),
    cwd = vim.fn.expand("%:p:h")
  })
end

function M.builtin()
  require('telescope.builtin').builtin({
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<cr>', actions.run_builtin)
      return true
    end
  })
end

return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require('telescope.builtin')[k]
    end
  end
})
