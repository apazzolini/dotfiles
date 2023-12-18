---@diagnostic disable: undefined-global, unused-local
local lush = require('lush')
local lyaml = require('lua-yaml/yaml')
local hsl = lush.hsl

local function read_yaml(file)
  local lines = {}
  for line in io.lines(file) do
    if #line > 0 and not line:match('^%s*#') then
      lines[#lines + 1] = line
    end
  end
  return lyaml.eval(table.concat(lines, '\n'))
end

-- local function get_dark_colors2()
--   local home = vim.fn.has('osx') == 1 and '/Users/andre' or vim.fn.has('win32') == 1 and 'L:/home/andre' or '/home/andre'
--   local parsed = read_yaml(home .. '/.dotfiles/systems/shared/alacritty.yml')
--   return {
--     black = '#1e2027',
--     red = '#f38ba8',
--     green = '#b1cfa9',
--     yellow = '#f2cdcd',
--     blue = '#9694D5',
--     magenta = '#be95ff',
--     cyan = '#DCB8E8',
--     white = '#c4cad5',
--     bright = {
--       magenta = '#ff007c',
--     },
--     fg = '#CDD6F4',
--     bg = '#1e1e2e',
--     gray1 = '#242534',
--     gray2 = '#45475a',
--     gray3 = '#6c7086',
--     gray4 = '#7f849c',
--     gray5 = '#9399b2',
--     gray6 = '#a6adc8',
--   }

--   -- return {
--   -- rosewater = "#f5e0dc",
--   -- flamingo = "#f2cdcd",
--   -- pink = "#f5c2e7",
--   -- mauve = "#cba6f7",
--   -- red = "#f38ba8",
--   -- maroon = "#eba0ac",
--   -- peach = "#fab387",
--   -- yellow = "#f9e2af",
--   -- green = "#a6e3a1",
--   -- teal = "#94e2d5",
--   -- sky = "#89dceb",
--   -- sapphire = "#74c7ec",
--   -- blue = "#89b4fa",
--   -- lavender = "#b4befe",
--   -- text = "#cdd6f4",
--   -- subtext1 = "#bac2de",
--   -- subtext0 = "#a6adc8",
--   -- overlay2 = "#9399b2",
--   -- overlay1 = "#7f849c",
--   -- overlay0 = "#6c7086",
--   -- surface2 = "#585b70",
--   -- surface1 = "#45475a",
--   -- surface0 = "#313244",
--   -- base = "#1e1e2e",
--   -- mantle = "#181825",
--   -- crust = "#11111b",
--   -- }
-- end

local function get_dark_colors()
  local home = vim.fn.has('osx') == 1 and '/Users/andre' or vim.fn.has('win32') == 1 and 'L:/home/andre' or '/home/andre'
  local parsed = read_yaml(home .. '/.dotfiles/systems/shared/alacritty.yml')
  return {
    black = parsed.colors.normal.black,
    red = parsed.colors.normal.red,
    green = parsed.colors.normal.green,
    yellow = parsed.colors.normal.yellow,
    blue = parsed.colors.normal.blue,
    magenta = parsed.colors.normal.magenta,
    cyan = parsed.colors.normal.cyan,
    white = parsed.colors.normal.white,
    bright = {
      magenta = parsed.colors.bright.magenta,
    },
    fg = parsed.colors.primary.foreground,
    bg = parsed.colors.primary.background,
    gray1 = parsed.colors.indexed_colors[1].color,
    gray2 = parsed.colors.indexed_colors[2].color,
    gray3 = parsed.colors.indexed_colors[3].color,
    gray4 = parsed.colors.indexed_colors[4].color,
    gray5 = parsed.colors.indexed_colors[5].color,
    gray6 = parsed.colors.indexed_colors[6].color,
  }
end

local function get_light_colors()
  return {
    black = hsl(210, 33, 98),
    red = hsl('#bf5656'),
    green = hsl('#5f8539'),
    yellow = hsl('#bfbf56'),
    blue = hsl(201, 50, 43),
    magenta = hsl(329, 36, 43),
    cyan = hsl('#56bf8b'),
    white = hsl('#0b1c2c'),
    bright = {
      magenta = hsl('#bf568b'),
    },
    fg = hsl(60, 5, 9),
    bg = hsl(210, 2, 84),
    gray1 = hsl(153, 1, 85),
    gray2 = hsl(153, 1, 80),
    gray3 = hsl(153, 1, 51),
    gray4 = hsl(153, 1, 42),
    gray5 = hsl(153, 1, 30),
    gray6 = hsl(153, 1, 19),
  }
end

local dark = vim.o.background == 'dark'
local c = dark and get_dark_colors() or get_light_colors()
local none = 'none'
local italic = 'italic'
local bold = 'bold'

local theme = lush(function(injected_functions)
  local sym = injected_functions.sym
  return {
    ColorColumn({ bg = c.gray2 }),
    Cursor({ gui = none, bg = c.red, fg = c.black }),
    CursorLine({ bg = c.gray1 }),
    CursorLineNr({ fg = c.gray4, gui = none }),
    Directory({ fg = c.green }),
    ErrorMsg({ fg = c.red, bg = none }),
    Folded({ guibg = none }),
    LineNr({ fg = dark and c.gray2 or c.gray5 }),
    ModeMsg({ fg = c.green, guibg = none }),
    MoreMsg({ fg = c.green }),
    NonText({ fg = c.gray1 }),
    Question({ fg = c.green }),
    qfFileName({ fg = c.green }),
    qfLineNr({ fg = c.cyan }),
    QuickFixLine({ bg = c.gray2, fg = c.gray6 }),
    Search({ fg = c.white, bg = c.gray2 }),
    SignColumn({ bg = none }),
    SpecialKey({ fg = c.blue }),
    StatusLine({ bg = c.gray1, gui = none }),
    TabLine({ guibg = none, fg = c.gray2, gui = none }),
    TabLineFill({ guibg = none, gui = none }),
    TabLineSel({ fg = c.magenta, bg = c.gray1, gui = none }),
    Title({ fg = c.blue }),
    VertSplit({ fg = c.gray3 }),
    Visual({ bg = c.gray2 }),
    IncSearch({ Search }),

    NormalFloat({ guibg = none }),
    FloatBorder({ fg = c.white }),
    Pmenu({ fg = c.white, bg = c.gray1 }),
    PmenuSel({ fg = c.black, bg = c.green }),
    MatchParen({ fg = c.magenta, guibg = none }),
    DiagnosticError({ fg = c.red }),
    DiagnosticWarn({ fg = c.yellow }),
    DiagnosticHint({ fg = c.yellow }),
    DiagnosticVirtualTextWarn({ DiagnosticWarn }),

    DiffAdd({ fg = c.gray1, bg = c.green }),
    DiffChange({ fg = c.gray1, bg = c.red }),
    DiffDelete({ fg = c.gray1, bg = c.gray2 }),
    DiffText({ fg = c.red }),

    Normal({ fg = c.fg }),
    Constant({ fg = c.blue }),
    String({ fg = c.green }),
    Identifier({ fg = c.blue }),
    Function({ fg = c.magenta }),
    Statement({ fg = c.blue }),
    Keyword({ fg = c.blue }),
    PreProc({ fg = c.blue }),
    Type({ fg = c.blue }),
    Special({ fg = c.blue }),
    Error({ fg = c.red, bg = none }),
    Comment({ fg = c.gray3, gui = italic }),
    Todo({ fg = c.red, guibg = none, gui = italic }),

    sym('@punctuation')({ Normal }),
    sym('@punctuation.delimiter')({ Normal }),
    sym('@punctuation.bracket')({ Normal }),
    sym('@punctuation.special')({ Normal }),
    sym('@constant')({ Normal }),
    sym('@parameter')({ Normal }),
    sym('@property')({ Normal }),
    sym('@variable')({ Normal }),
    sym('@variable.builtin')({ Normal }),

    sym('@function')({ fg = c.magenta, gui = bold }),
    sym('@method')({ sym('@function') }),
    sym('@constructor')({ sym('@function') }),

    sym('@conditional')({ fg = c.blue }),
    sym('@namespace')({ fg = c.blue }),
    sym('@operator')({ fg = c.blue }),
    sym('@type')({ fg = c.cyan, gui = bold }),
    -- sym('@type')({ fg = hsl(315, 82, 87), gui = bold }),
    sym('@type.builtin')({ sym('@type') }),
    sym('@tag')({ fg = c.cyan }),
    sym('@tag.delimiter')({ sym('@tag') }),
    sym('@tag.attribute')({ fg = c.cyan }),
    sym('@reactHook')({ fg = c.cyan }),
    sym('@className')({ fg = c.red }),
    sym('@function.call')({ fg = c.yellow }),
    sym('@method.call')({ fg = c.yellow }),

    -- Vimwiki
    VimWikiLink({ guibg = none, gui = none, fg = c.blue }),
    VimwikiHr({ fg = c.magenta }),
    VimwikiHeader1({ fg = c.magenta }),
    VimwikiHeader2({ fg = c.magenta }),
    VimwikiList({ Normal }),
    VimwikiCode({ Normal }),

    -- Floaterm
    -- FloatermBorder({ fg = hsl('#1e1f2b') }),

    -- Telescope
    TelescopeMatching({ fg = c.red }),
    TelescopeBorder({ fg = c.magenta }),
    TelescopePromptBorder({ TelescopeBorder }),
    TelescopeResultsBorder({ TelescopeBorder }),
    TelescopePreviewBorder({ TelescopeBorder }),
    TelescopePromptPrefix({ TelescopeBorder }),
    TelescopeSelection({ fg = c.cyan }),
    TelescopeSelectionCaret({ fg = c.cyan }),
    TelescopeMultiSelection({ fg = c.magenta }),
    TelescopePromptCounter({ fg = c.magenta }),

    -- Hop
    HopNextKey({ fg = c.bright.magenta, gui = none, bg = c.gray1 }),
    HopNextKey1({ fg = c.bright.magenta, gui = none, bg = c.gray1 }),
    HopNextKey2({ fg = c.bright.magenta, gui = none, bg = c.gray1 }),

    -- Neotree
    NeoTreeRootName({ gui = none, fg = c.magenta }),
    NeoTreeFloatBorder({ fg = c.white }),

    -- Dadbod
    NotificationInfo({ bg = c.gray1, gui = none }),

    -- Treesitter Context
    TreesitterContextLineNumber({ fg = c.green }),
  }
end)

-- Light theme
-- call s:HL('HopNextKey',  s:wBold, s:wRed)
-- call s:HL('HopNextKey1', s:wBold, s:wBlue)
-- call s:HL('HopNextKey2', s:wBold, s:wMagenta)
-- call s:HL('ColorColumn', 'guibg=#d5d6d7')
-- call s:HL('QuickFixLine', s:wBg2, s:wFg5)
-- call s:HL('Visual', s:wBg5)
-- call s:HL('Search', s:wBg4)
-- hi! Normal ctermbg=NONE guibg=#d5d6d7 guifg=#0c1c2b

return theme
