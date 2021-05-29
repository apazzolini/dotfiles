TelescopeMapArgs = TelescopeMapArgs or {}

local map_tele = function(key, f, options, buffer)
  local map_key = vim.api.nvim_replace_termcodes(key .. f, true, true, true)

  TelescopeMapArgs[map_key] = options or {}

  local mode = "n"
  local rhs = string.format(
    "<cmd>lua require('andre.telescope')['%s'](TelescopeMapArgs['%s'])<CR>",
    f,
    map_key
  )

  local map_options = {
    noremap = true,
    silent = true,
  }

  if not buffer then
    vim.api.nvim_set_keymap(mode, key, rhs, map_options)
  else
    vim.api.nvim_buf_set_keymap(0, mode, key, rhs, map_options)
  end
end

map_tele(',e',  'find_files')
map_tele(',E',  'current_dir_files')
map_tele(',b',  'buffers')
map_tele(',fd', 'projects')
map_tele(',fo', 'oldfiles')
map_tele(',ff', 'git_files')
map_tele(',B', 'git_branches')
map_tele(',fh', 'help_tags')
map_tele(',fe', 'lsp_workspace_diagnostics', {
  layout_strategy = 'vertical',
})
map_tele(',fb', 'builtin')
map_tele(',a',  'live_grep')
map_tele(',fw',  'git_worktrees')
-- map_tele(',p',  'projects')
map_tele(',W',  'grep_string', {
  short_path = true,
  word_match = '-w',
  only_sort_text = true,
  layout_strategy = 'vertical'
})
