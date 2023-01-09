local select_multiple = require('andre.telescope.select_multiple')

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
