local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local flatten = vim.tbl_flatten

local opts = {}
opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

local shortcuts = {}
shortcuts['t'] = '*.tsx'

local custom_grep = finders.new_job(function(prompt)
  if not prompt or prompt == '' then
    return nil
  end

  local prompt_split = vim.split(prompt, ' ')

  local args = { 'rg' }
  if prompt_split[1] then
    table.insert(args, '-e')
    table.insert(args, prompt_split[1])
  end

  if prompt_split[2] then
    table.insert(args, '-g')

    local pattern
    if shortcuts[prompt_split[2]] then
      table.insert(args, shortcuts[prompt_split[2]])
    else
      table.insert(args, prompt_split[2])
    end
    table.insert(args, pattern)
  end

  return flatten({
    args,
    { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
  })
end, make_entry.gen_from_vimgrep(
  opts
), opts.max_results, opts.cwd)

pickers.new(opts, {
  prompt_title = 'rg',
  finder = custom_grep,
  previewer = conf.grep_previewer(opts),
  sorter = require('telescope.sorters').empty(),
}):find()
