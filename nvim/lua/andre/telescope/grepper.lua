local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local conf = require('telescope.config').values
local flatten = vim.tbl_flatten

return function(opts)
  opts = opts or {}
  opts.temp__scrolling_limit = 10000
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  opts.shortcuts = opts.shortcuts
    or {
      ['l'] = '*.lua',
      ['v'] = '*.vim',
      ['n'] = '*.{vim,lua}',
      ['t'] = 'tokens-server/src/**/**',
      ['s'] = 'server/src/**/**',
      ['f'] = 'frontend/src/**/**',
      ['c'] = 'common/src/**/**',
      ['b'] = 'common-backend/src/**/**',
    }
  opts.pattern = opts.pattern or '%s'

  local custom_grepper = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local prompt_split = vim.split(prompt, '  ')

      local args = { 'rg' }
      if prompt_split[1] then
        table.insert(args, '-e')
        table.insert(args, prompt_split[1])
      end

      if prompt_split[2] then
        table.insert(args, '-g')

        local pattern
        if opts.shortcuts[prompt_split[2]] then
          pattern = opts.shortcuts[prompt_split[2]]
        else
          if prompt_split[2]:sub(1, 1) == '.' then
            pattern = '*.' .. prompt_split[2]:sub(2) .. '**'
          elseif prompt_split[2]:sub(1, 1) == ' ' then
            pattern = prompt_split[2]:sub(2) .. '**'
          else
            pattern = prompt_split[2] .. '**/**'
          end
        end

        table.insert(args, string.format(opts.pattern, pattern))
      end

      local result = flatten({
        args,
        { '--hidden', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
      })
      return result
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  local prompt_title = 'Custom Grep'
  if opts.hidden then
    prompt_title = prompt_title .. ' (with hidden files)'
  end

  pickers
    .new(opts, {
      -- debounce = 100,
      prompt_title = prompt_title,
      finder = custom_grepper,
      previewer = conf.grep_previewer(opts),
      sorter = require('telescope.sorters').empty(),
      --     sorter = sorters.highlighter_only(opts),
    })
    :find()
end
