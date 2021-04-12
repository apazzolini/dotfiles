local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')
local vcs = require('galaxyline.provider_vcs')

-- Don't show the statusline in these windows
gl.short_line_list = {'nerdtree'}

-----------------------------------COLORS----------------------------------- {{{

local dark = {
  bg = '#2b3034',
  fg = '#c7ccd1',
  fg_dim = '#747c84',
  error = '#D5869E',
  black = '#1c2023',

  -- mode colors
  normal = '#a2c7a9', -- green
  insert = '#95aec7', -- blue
  command = '#dcdcaa', -- yellow
  visual = '#ae95c7', -- purple
  replace = '#c795ae' -- red
}
local light = { }

---------------------------------------------------------------------------- }}}
------------------------------CUSTOM FUNCTIONS------------------------------ {{{

-- Return a closure function of the hex color
function color(val)
  return function()
    if vim.o.background ~= nil and vim.o.background == "light" then
      return light[val]
    else
      return dark[val]
    end
  end
end

-- Used to get a hex color
function get_color(val)
  if vim.o.background ~= nil and vim.o.background == "light" then
    return light[val]
  else
    return dark[val]
  end
end

---------------------------------------------------------------------------- }}}
----------------------------------SHORTLINE--------------------------------- {{{

gls.short_line_left = {
  {
    ShortFileName = {
      provider = function()
        if vim.fn.expand('%:t'):find('NERD_tree') then return '' end

        local name = '  ' .. vim.fn.expand('%:h') .. '/' .. vim.fn.expand('%:t')
        if vim.bo.modified then name = name .. ' [+]' end
        return name
      end,
      condition = condition.buffer_not_empty,
      highlight = {color('fg_dim'), color('bg')}
    }
  }
}

---------------------------------------------------------------------------- }}}
---------------------------------STATUSLINE--------------------------------- {{{
------------------------------------LEFT------------------------------------ {{{

gls.left = {
  {
    ViMode = {
      provider = function()
        local alias = {
          n = 'NORMAL',
          i = 'INSERT',
          c = 'COMMAND',
          v = 'VISUAL',
          V = 'VISUAL',
          [''] = 'VISUAL'
        }
        local mode_color = {
          n = get_color('normal'),
          i = get_color('insert'),
          c = get_color('command'),
          v = get_color('visual'),
          V = get_color('visual'),
          [' '] = get_color('visual')
        }
        mode = vim.fn.mode()
        if mode_color[mode] ~= nil then
          vim.api.nvim_command('hi GalaxyViMode guifg=' .. get_color('black') .. ' guibg=' ..mode_color[mode])
          vim.api.nvim_command('hi GalaxyViModeInv guifg=' ..mode_color[mode])
        end
        return string.format('  %s ', alias[mode])
      end,
      highlight = {color('bg'), color('bg')}
    }
  }, {
    DiagnosticError = {
      provider = 'DiagnosticError',
      icon = '  ✗ ',
      highlight = {color('black'), color('error')}
    }
  }, {
    DiagnosticWarn = {
      provider = 'DiagnosticWarn',
      icon = '  ✗ ',
      highlight = {color('black'), color('error')}
    }
  }, {
    DiagnosticInfo = {
      provider = 'DiagnosticInfo',
      icon = '  ✗ ',
      highlight = {color('black'), color('error')},
    }
  }, {
    FileName = {
      provider = function()
        local name = '  ' .. vim.fn.expand('%:h') .. '/' .. vim.fn.expand('%:t')
        if vim.bo.modified then name = name .. ' [+]' end
        return name
      end,
      condition = condition.buffer_not_empty,
      highlight = {color('fg'), color('bg')}
    }
  }
}

---------------------------------------------------------------------------- }}}
------------------------------------RIGHT----------------------------------- {{{

gls.right = {
  {
    FileTypeName = {
      provider = function() return '[' .. vim.bo.filetype .. ']' end,
      condition = condition.buffer_not_empty,
      separator = ' ',
      separator_highlight = {color('black'), color('bg')},
      highlight = {color('fg'), color('bg')}
    }
  }, {
    GitBranch = {
      provider = function() return '[' .. vcs.get_git_branch() .. ']' end,
      condition = vcs.get_git_branch,
      separator = ' ',
      separator_highlight = {color('black'), color('bg')},
      highlight = {color('fg'), color('bg')}
    }
  }, {
    FilePosition = {
      provider = function()
        local line = vim.fn.line('.')
        local column = vim.fn.col('.')
        return string.format("[%d:%d]", line, column)
      end,
      separator = ' ',
      separator_highlight = {color('black'), color('bg')},
      highlight = {color('fg'), color('bg')}
    }
  }
}

---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
-- Force manual load so that nvim boots with a status line

gl.load_galaxyline()
