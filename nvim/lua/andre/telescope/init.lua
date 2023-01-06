if not pcall(require, 'telescope') then
  return
end

package.loaded['andre.telescope'] = nil

package.loaded['andre.telescope.sorter'] = nil
local andre_sorter = require('andre.telescope.sorter')

require('andre.telescope.mappings')

local action_state = require('telescope.actions.state')
local action_set = require('telescope.actions.set')
local actions = require('telescope.actions')

local select_multiple = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = current_picker:get_multi_selection()

  if #multi_selections > 0 then
    actions.send_selected_to_qflist(prompt_bufnr)
    actions.open_qflist(prompt_bufnr)
  else
    action_set.select(prompt_bufnr, 'default')
  end
end

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
    generic_sorter = andre_sorter()
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
}

require('telescope').setup(telescope_opts)

local M = {}

function M.custom_grep()
  package.loaded['andre.telescope.grepper'] = nil
  require('andre.telescope.grepper')({
    attach_mappings = function(_, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

function M.custom_grep_hidden()
  package.loaded['andre.telescope.grepper'] = nil
  require('andre.telescope.grepper')({
    hidden = true,
    attach_mappings = function(_, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

-- function M.live_grep()
--   require('telescope.builtin').live_grep({
--     prompt_title = '~ live grep ~',
--     attach_mappings = function(prompt_bufnr, map)
--       map('i', '<cr>', select_multiple)
--       return true
--     end,
--   })
--   -- require('telescope').extensions.fzf_writer.staged_grep({
--   --   prompt_title = '~ staged grep ~',
--   --   attach_mappings = function(prompt_bufnr, map)
--   --     map('i', '<cr>', select_multiple)
--   --     return true
--   --   end,
--   -- })
-- end

function M.grep_string()
  require('telescope.builtin').grep_string({
    prompt_title = '~ grep string ~',
    short_path = true,
    word_match = '-w',
    only_sort_text = true,
    attach_mappings = function(_, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

function M.current_dir_files()
  require('telescope.builtin').find_files({
    prompt_title = string.format('~ files in [%s] ~', vim.fn.expand('%:h')),
    cwd = vim.fn.expand('%:p:h'),
    hidden = true,
  })
end

function M.dotfiles()
  require('telescope.builtin').find_files({
    prompt_title = string.format('~ dotfiles ~'),
    cwd = '~/.dotfiles',
    hidden = true,
  })
end

function M.git_changed_on_branch()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local sorters = require('telescope.sorters')
  local previewers = require('telescope.previewers')

  pickers.new({
    prompt_title = '~ git changed (current branch) ~',
    finder = finders.new_oneshot_job({ 'git', 'diff', '--name-only', '--diff-filter=ACMR', '--relative', 'develop' }, {}),
    sorter = sorters.get_fzy_sorter(),
    mappings = {
      i = {
        ['<cr>'] = select_multiple,
      },
    },
    previewer = previewers.git_file_diff.new({}),
    layout_config = { width = 140, height = 0.8 },
  }, {}):find()
end

return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require('telescope.builtin')[k]
    end
  end,
})
