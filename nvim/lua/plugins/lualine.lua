return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local colors = {
      bg0 = '#464e53',
      bg1 = '#343d42',
      fg = '#1e2027',
      fg2 = '#c8cedc',
      red = '#FF8AA7',
      green = '#CCD7BC',
      yellow = '#EAD1D1',
      blue = '#B2DCCD',
      magenta = '#b088d7',
      bold_red = '#d19b9b',
    }

    if vim.g.isNotes then
      colors.fg = '#181816'
      colors.fg2 = '#181816'
      colors.bg0 = '#bfc0c0'
      colors.bg1 = '#CBCDCC'
      colors.blue = colors.bg0
    end

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

    local sections = {
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
          sources = { 'nvim_diagnostic' },
          sections = { 'error', 'warn', 'info' }, -- 'hint'
          color_error = colors.red,
          color_warn = nil,
          color_info = nil,
          color_hint = nil,
          symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
        },
      },
      lualine_x = { 'filetype' },
      lualine_y = { 'branch' },
      lualine_z = { 'location' },
    }

    if vim.g.isNotes then
      sections.lualine_a = {}
      sections.lualine_c = {}
      sections.lualine_x = {}
      sections.lualine_y = {}
    end

    require('lualine').setup({
      options = {
        icons_enabled = false,
        theme = theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {},
      },
      sections = sections,
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
        'neo-tree',
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
