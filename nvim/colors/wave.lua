---@diagnostic disable: undefined-global, unused-local
local lush = require('lush')
local ltoml = require('lua-toml/toml')
local hsl = lush.hsl

local function read_toml(file)
  local lines = {}
  for line in io.lines(file) do
    if #line > 0 and not line:match('^%s*#') then
      lines[#lines + 1] = line
    end
  end
  return ltoml.parse(table.concat(lines, '\n'))
end

local function get_dark_colors()
  local home = vim.fn.has('osx') == 1 and '/Users/andre' or vim.fn.has('win32') == 1 and 'L:/home/andre' or '/home/andre'
  local parsed = read_toml(home .. '/.dotfiles/systems/shared/alacritty.toml')

  return {
    -- black = '#1e2027',
    -- blue = '#BFA4F0',
    -- cyan = '#E4BBE4',
    -- green = '#A8D7AF',
    -- magenta = '#B98AFF',
    -- red = '#FF87A5',
    -- white = '#c4cad5',
    -- yellow = '#f2cdcd',
    -- bg = '#1E1B2A',
    -- fg = '#D3D8ED',
    -- gray1 = '#242333',
    -- gray2 = '#45475a',
    -- gray3 = '#6c7086',
    -- gray4 = '#7f849c',
    -- gray5 = '#9399b2',
    -- gray6 = '#a6adc8',
    -- bright = {
    --   magenta = '#ff007c',
    -- },

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
      green = parsed.colors.bright.green,
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
    Directory({ fg = c.gray3 }),
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
    Search({ bg = c.gray2 }),
    SignColumn({ bg = none }),
    SpecialKey({ fg = c.blue }),
    StatusLine({ bg = c.gray1, gui = none }),
    TabLine({ guibg = none, fg = c.gray2, gui = none }),
    TabLineFill({ guibg = none, gui = none }),
    TabLineSel({ fg = c.magenta, bg = c.gray1, gui = none }),
    Title({ fg = c.blue }),
    VertSplit({ fg = c.gray3 }),
    Visual({ bg = c.gray2 }),
    CurSearch({ Search }),
    IncSearch({ Search }),

    NormalFloat({ guibg = none }),
    FloatBorder({ fg = c.white }),
    Pmenu({ fg = c.white, bg = c.gray1 }),
    PmenuSel({ fg = c.black, bg = c.green }),
    MatchParen({ fg = c.red, guibg = none }),
    DiagnosticError({ fg = c.red }),
    DiagnosticWarn({ fg = c.yellow }),
    DiagnosticHint({ fg = c.yellow }),
    DiagnosticVirtualTextWarn({ DiagnosticWarn }),

    DiffAdd({ fg = c.gray1, bg = c.green }),
    DiffChange({ fg = c.gray1, bg = c.red }),
    DiffDelete({ fg = c.gray1, bg = c.gray2 }),
    DiffText({ fg = c.red }),
    diffAdded({ fg = c.green }),
    diffRemoved({ fg = c.red }),

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
    Todo({ fg = c.bright.magenta, guibg = none, gui = italic }),
    TodoFgTODO({ fg = c.bright.green, guibg = none, gui = italic }),
    TodoBgTODO({ fg = c.bright.green, guibg = none, gui = italic }),
    LspSignatureActiveParameter({ fg = c.red }),

    sym('@punctuation')({ Normal }),
    sym('@punctuation.delimiter')({ Normal }),
    sym('@punctuation.bracket')({ Normal }),
    sym('@punctuation.special')({ Normal }),
    sym('@constant')({ Normal }),
    sym('@parameter')({ Normal }),
    sym('@property')({ Normal }),
    sym('@variable')({ Normal }),
    sym('@variable.builtin')({ Normal }),

    sym('@function')({ fg = c.red, gui = bold }),
    sym('@method')({ sym('@function') }),

    sym('@conditional')({ fg = c.blue }),
    sym('@namespace')({ fg = c.blue }),
    sym('@operator')({ fg = c.blue }),
    sym('@type')({ fg = c.cyan, gui = bold }),
    -- sym('@type')({ fg = hsl(315, 82, 87), gui = bold }),
    sym('@type.builtin')({ sym('@type') }),
    sym('@constructor')({ sym('@type') }),
    sym('@tag')({ fg = c.cyan }),
    sym('@tag.delimiter')({ sym('@tag') }),
    sym('@tag.attribute')({ fg = c.cyan }),
    sym('@reactHook')({ fg = c.cyan }),
    sym('@className')({ fg = c.red }),
    sym('@function.call')({ fg = c.yellow }),
    sym('@method.call')({ fg = c.yellow }),
    sym('@function.method.call')({ fg = c.yellow }),

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
    NeoTreeDirectoryName({ fg = c.green }),

    -- Dadbod
    NotificationInfo({ bg = c.gray1, gui = none }),

    -- Treesitter Context
    TreesitterContextLineNumber({ fg = c.green }),

    -- Navbuddy
    NavbuddyClass({ fg = c.green }),
    NavbuddyModule({ fg = c.green }),
    NavbuddyMethod({ fg = c.yellow }),

    -- cmp
    CmpItemMenu({ fg = c.gray3 }),
    CmpItemKind({ fg = c.gray3 }),
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
