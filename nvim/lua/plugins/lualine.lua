return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local colors = {
      bg0 = '#464e53',
      bg1 = '#343d42',
      fg = '#1e2027',
      fg2 = '#c8cedc',
      red = '#de718b',
      green = '#b1cfa9',
      yellow = '#e8dcb0',
      blue = '#9494bc',
      magenta = '#b088d7',
      bold_red = '#d19b9b',
    }

    -- LuaFormatter on
    local b = { bg = colors.bg0, fg = colors.fg2, gui = 'bold' }
    local c = { bg = colors.bg1, fg = colors.fg2 }

    local theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.fg },
        b = b,
        c = c,
      },
      insert = {
        a = { bg = colors.yellow, fg = colors.fg },
        b = b,
        c = c,
      },
      visual = {
        a = { bg = colors.red, fg = colors.fg },
        b = b,
        c = c,
      },
      replace = {
        a = { bg = colors.bold_red, fg = colors.fg },
        b = b,
        c = c,
      },
      command = {
        a = { bg = colors.green, fg = colors.fg },
        b = b,
        c = c,
      },
      terminal = {
        a = { bg = colors.magenta, fg = colors.fg },
        b = b,
        c = c,
      },
      inactive = {
        c = { bg = colors.bg1, fg = 8 },
      },
    }

    require('lualine').setup({
      options = {
        icons_enabled = false,
        theme = theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {},
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          {
            'filename',
            path = 1,
          },
        },
        lualine_c = {
          {
            'diagnostics',
            -- table of diagnostic sources, available sources:
            -- nvim_lsp, coc, ale, vim_lsp
            sources = { 'nvim_diagnostic' },
            -- displays diagnostics from defined severity
            sections = { 'error', 'warn', 'info' }, -- 'hint'
            -- all colors are in format #rrggbb
            color_error = colors.red, -- changes diagnostic's error foreground color
            color_warn = nil, -- changes diagnostic's warn foreground color
            color_info = nil, -- Changes diagnostic's info foreground color
            color_hint = nil, -- Changes diagnostic's hint foreground color
            symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
          },
        },
        lualine_x = { 'filetype' },
        lualine_y = { 'branch' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {
        'quickfix',
        'nvim-tree',
        {
          filetypes = { 'fugitive' },
          sections = {
            lualine_a = { 'FugitiveHead' },
            lualine_z = { 'location' },
          },
        },
      },
    })
  end,
}
