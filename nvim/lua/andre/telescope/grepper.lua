local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local conf = require('telescope.config').values

local shortcuts = {}
shortcuts['f'] = 'systems/osx'

return function(opts)
  local rg_args = {
    { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
  }

  if opts.hidden then
    table.insert(rg_args[1], '--hidden')
  end

  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

  local custom_grepper = finders.new_job(function(prompt)
    if not prompt or prompt == '' then
      return nil
    end

    local prompt_split = vim.split(prompt, '  ')
    local args = {}

    if prompt_split[1] then
      table.insert(args, prompt_split[1])
    end

    if prompt_split[2] and prompt_split[2] ~= '' then
      if shortcuts[prompt_split[2]:sub(1, 1)] then
        local path = shortcuts[prompt_split[2]:sub(1, 1)] .. prompt_split[2]:sub(2)
        table.insert(args, path)
      else
        table.insert(args, prompt_split[2])
      end
    else
      table.insert(args, '.')
    end

    return vim.tbl_flatten({ rg_args, args })
  end, opts.entry_maker or make_entry.gen_from_vimgrep(
    opts
  ), opts.max_results, opts.cwd)

  local prompt_title = 'Custom Grep'
  if opts.hidden then
    prompt_title = prompt_title .. ' (with hidden files)'
  end

  pickers.new(opts, {
    prompt_title = prompt_title,
    finder = custom_grepper,
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
  }):find()
end
