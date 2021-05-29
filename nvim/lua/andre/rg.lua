local Job = require('plenary.job')

local M = {}

function M.rg(arg, cwd)
  local entries = {}

  local opts = {
    command = '/usr/local/bin/rg',
    args = {
      '--color=never',
      '--follow',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      arg,
    },
    on_stdout = function(_, data)
      if cwd then
        data = cwd .. '/' .. data
      end

      table.insert(entries, data)
    end,
  }

  if cwd then
    opts.cwd = cwd
  end

  local job = Job:new(opts)

  job:after(vim.schedule_wrap(function(a,b)
    vim.fn.setqflist({}, " ", {
      title = cmd,
      lines = entries,
    })
    vim.cmd [[copen]]
  end))

  job:start()
end

local opts = { noremap = true }
vim.api.nvim_set_keymap('n', ',A', ':lua require("andre.rg").rg ', opts)

return M
