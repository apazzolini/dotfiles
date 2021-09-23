if not pcall(require, 'telescope') then
  return
end

package.loaded['andre.telescope'] = nil

require('andre.telescope.mappings')

local action_state = require('telescope.actions.state')
local action_set = require('telescope.actions.set')
local actions = require('telescope.actions')

local select_multiple = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = current_picker:get_multi_selection()

  if #multi_selections > 0 then
    actions.send_selected_to_qflist(prompt_bufnr)
    actions.open_qflist()
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
      '%.jpg',
      '%.png',
      '%.woff',
      '%.ttf',
      '%.eot',
      '%.svg',
      'yarn.lock',
      'package%-lock.json',
      '^%.git%/*',
      '%/node_modules/*',
      '%external-src/*',
      'systems/osx/iTerm2/com.googlecode.iterm2.plist',
      'util/cce37d14-ebc8-40c0-b942-cbc8fd7b34cc.json',
      'util/7236f71d-5a53-11e8-b364-0a58647f9b0f-telemetry.json',
    },

    mappings = {
      i = {
        ['<c-j>'] = actions.move_selection_next,
        ['<c-k>'] = actions.move_selection_previous,
        ['<esc>'] = actions.close,
        ['<C-o>'] = actions.send_to_qflist + actions.open_qflist,
      },
    },
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
      layout_config = { width = 110 },
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
      layout_config = { width = 110 },
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
      layout_config = { width = 110 },
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    fzf_writer = {
      minimum_grep_characters = 2,
      minimum_files_characters = 2,
      use_highlighter = true,
    },
  },
}

require('telescope').setup(telescope_opts)

if vim.fn.has('win32') == 0 then
  require('telescope').load_extension('fzy_native')
end

local M = {}

function M.custom_grep()
  package.loaded['andre.telescope.grepper'] = nil
  require('andre.telescope.grepper')({
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

function M.live_grep()
  require('telescope.builtin').live_grep({
    prompt_title = '~ live grep ~',
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
  -- require('telescope').extensions.fzf_writer.staged_grep({
  --   prompt_title = '~ staged grep ~',
  --   attach_mappings = function(prompt_bufnr, map)
  --     map('i', '<cr>', select_multiple)
  --     return true
  --   end,
  -- })
end

function M.grep_string()
  require('telescope.builtin').grep_string({
    prompt_title = '~ grep string ~',
    short_path = true,
    word_match = '-w',
    only_sort_text = true,
    attach_mappings = function(prompt_bufnr, map)
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

return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require('telescope.builtin')[k]
    end
  end,
})
