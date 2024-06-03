local select_multiple = require('plugins.telescope.select_multiple')

local M = {}

function M.custom_grep()
  package.loaded['plugins.telescope.grepper'] = nil
  require('plugins.telescope.grepper')({
    attach_mappings = function(_, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

function M.smart_open()
  require('telescope').extensions.smart_open.smart_open({
    cwd_only = true,
    prompt_title = '~ smart open ~',
    match_algorithm = 'fzy',
    previewer = false,
    theme = 'dropdown',
    layout_config = { width = 120, height = 15 },
    attach_mappings = function(_, map)
      map('i', '<cr>', select_multiple)
      return true
    end,
  })
end

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

function M.code_spelunker(opts)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local make_entry = require('telescope.make_entry')

  pickers
    .new({
      prompt_title = '~ code spelunker ~',
      finder = finders.new_job(function(prompt)
        local parts = { 'cs', '--format', 'vimgrep' }
        for word in prompt:gmatch('%w+') do
          table.insert(parts, word)
        end
        return parts
      end, make_entry.gen_from_vimgrep(opts)),
      previewer = previewers.vim_buffer_vimgrep.new({}),
    }, {})
    :find()
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

  pickers
    .new({
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
    }, {})
    :find()
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
