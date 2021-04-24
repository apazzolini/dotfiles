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

-- require('telescope').load_extension('fzy_native')
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

    -- file_sorter = require('telescope.sorters').get_fzy_sorter,
    file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

    file_ignore_patterns = {
      "yarn.lock",
      "package%-lock.json",
      "git/*",
      "%/node_modules/%",
      "util/cce37d14-ebc8-40c0-b942-cbc8fd7b34cc.json",
      "util/7236f71d-5a53-11e8-b364-0a58647f9b0f-telemetry.json",
    },

    mappings = {
      i = {
        ["<c-j>"] = actions.move_selection_next,
        ["<c-k>"] = actions.move_selection_previous,
        ["<esc>"] = actions.close,
        ["<cr>"] = select_multiple,
        ["<bs>"] = '<bs>',
        ["<C-o>"] = actions.send_to_qflist + actions.open_qflist,
      },
    }
  },
  extensions = {
    fzf = {
      -- override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    },
    -- fzy_native = {
    -- override_generic_sorter = true,
    -- override_file_sorter = true,
    -- },
    -- fzf_writer = {
      -- minimum_grep_characters = 2,
      -- minimum_files_characters = 2,

      -- -- Disabled by default.
      -- -- Will probably slow down some aspects of the sorter, but can make color highlights.
      -- -- I will work on this more later.
      -- -- use_highlighter = true,
    -- }
  }
}

if vim.fn.has('win32') == 1 then
  telescope_opts.defaults.extensions = {}
  telescope_opts.defaults.layout_strategy = 'vertical'
end

require('telescope').setup(telescope_opts)

-- Telescope extensions must be loaded after the setup function
require('telescope').load_extension('git_worktree')
require('telescope').load_extension('project')

if vim.fn.has('win32') == 0 then
  require('telescope').load_extension('fzf')
end

local M = {}

function M.live_grep()
  -- require('telescope').extensions.fzf_writer.files({
    -- prompt_title = "~ live grep1 ~",
    -- layout_strategy = 'vertical',
    -- layout_config = {
      -- mirror = true,
      -- preview_height = 0.20,
    -- }
  -- })
  require('telescope.builtin').live_grep {
    prompt_title = "~ live grep ~",
    layout_strategy = 'vertical',
    layout_config = {
      mirror = true,
      preview_height = 0.20,
    }
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
    hidden = true,
  })
end

function M.current_dir_files()
  require('telescope.builtin').find_files({
    prompt_title = string.format("~ files in [%s] ~", vim.fn.expand("%:h")),
    cwd = vim.fn.expand("%:p:h"),
    hidden = true,
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

function M.git_worktrees()
  require('telescope').extensions.git_worktree.git_worktrees({})
end

local project_actions = require("telescope._extensions.project_actions")
function M.projects()
  require('telescope').extensions.project.project({
    change_dir = true,
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<cr>', actions.select_default)
      map('i', '<esc>', '<esc>')
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
