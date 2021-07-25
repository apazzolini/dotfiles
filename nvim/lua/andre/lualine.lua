local colors = {
  bg0 = '#323d43',
  bg1 = '#3c474d',
  bg3 = '#505a60',
  fg = '#c7ccd1',
  aqua = '#87c095',
  green = '#a2c7a9',
  orange = '#e39b7b',
  purple = '#d39bb6',
  red = '#e68183',
  grey1 = '#adb3ba',
  yellow = '#EFE7CA',
}

-- LuaFormatter on
local theme = {
  normal = {
    a = { bg = colors.green, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  insert = {
    a = { bg = colors.yellow, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  visual = {
    a = { bg = colors.red, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  replace = {
    a = { bg = colors.orange, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  command = {
    a = { bg = colors.aqua, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  terminal = {
    a = { bg = colors.purple, fg = colors.bg0, gui = 'bold' },
    b = { bg = colors.bg3, fg = colors.fg },
    c = { bg = colors.bg1, fg = colors.fg },
  },
  inactive = {
    a = { bg = colors.bg1, fg = colors.grey1, gui = 'bold' },
    b = { bg = colors.bg1, fg = colors.grey1 },
    c = { bg = colors.bg1, fg = colors.grey1 },
  },
}

require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = theme,
    component_separators = { '', '' },
    section_separators = { '', '' },
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
        sources = { 'nvim_lsp' },
        -- displays diagnostics from defined severity
        sections = { 'error', 'warn', 'info' }, -- 'hint'
        -- all colors are in format #rrggbb
        color_error = nil, -- changes diagnostic's error foreground color
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
        lualine_a = { vim.fn.FugitiveHead },
        lualine_z = { 'location' },
      },
    },
  },
})
