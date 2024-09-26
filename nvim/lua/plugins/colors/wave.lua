---@diagnostic disable: undefined-global, unused-local
local lush = require('lush')
local hsl = lush.hsl

local function get_dark_colors()
  return {
    black = hsl(227, 14, 14),
    red = hsl(345, 100, 77),
    green = hsl(159, 38, 78),
    yellow = hsl(0, 38, 87),
    blue = hsl(444, 25, 79),
    magenta = hsl(264, 92, 79),
    cyan = hsl(335, 72, 79),
    white = hsl(219, 17, 81),

    bg = hsl(233, 22, 13),
    fg = hsl(229, 42, 88),

    gray1 = hsl(235, 24, 19),
    gray2 = hsl(234, 19, 30),
    gray3 = hsl(231, 11, 48),
    gray4 = hsl(230, 13, 56),
    gray5 = hsl(229, 17, 64),
    gray6 = hsl(228, 24, 72),

    bright = {
      black = hsl(230, 14, 42),
      red = hsl(350, 100, 67),
      green = hsl(155, 99, 55),
      yellow = hsl(42, 87, 84),
      blue = hsl(272, 52, 71),
      magenta = hsl(331, 100, 50),
      cyan = hsl(182, 45, 68),
      white = hsl(232, 22, 70),
    },
  }
end

local function get_light_colors()
  return {
    black = hsl(210, 33, 98),
    red = hsl('#bf5656'),
    green = hsl('#5f8539'),
    yellow = hsl('#bfbf56'),
    cyan = hsl(201, 50, 43),
    magenta = hsl(329, 36, 43),
    blue = hsl('#56bf8b'),
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
    ModeMsg({ fg = c.yellow, guibg = none }),
    MoreMsg({ fg = c.yellow }),
    NonText({ fg = c.gray1 }),
    Question({ fg = c.yellow }),
    qfFileName({ fg = c.cyan }),
    qfLineNr({ fg = c.blue }),
    QuickFixLine({ bg = c.gray2, fg = c.gray6 }),
    Search({ bg = c.gray2 }),
    SignColumn({ bg = none }),
    SpecialKey({ fg = c.cyan }),
    StatusLine({ bg = c.gray1, gui = none }),
    TabLine({ guibg = none, fg = c.gray2, gui = none }),
    TabLineFill({ guibg = none, gui = none }),
    TabLineSel({ fg = c.magenta, bg = c.gray1, gui = none }),
    Title({ fg = c.cyan }),
    VertSplit({ fg = c.gray3 }),
    Visual({ bg = c.gray2 }),
    CurSearch({ Search }),
    IncSearch({ Search }),

    NormalFloat({ guibg = none }),
    FloatBorder({ fg = c.white }),
    Pmenu({ fg = c.white, bg = c.gray1 }),
    PmenuSel({ fg = c.black, bg = c.blue }),
    MatchParen({ fg = c.red, guibg = none }),
    DiagnosticError({ fg = c.red }),
    DiagnosticWarn({ fg = c.green }),
    DiagnosticHint({ fg = c.green }),
    DiagnosticVirtualTextWarn({ DiagnosticWarn }),

    DiffAdd({ fg = c.gray1, bg = c.yellow }),
    DiffChange({ fg = c.gray1, bg = c.red }),
    DiffDelete({ fg = c.gray1, bg = c.gray2 }),
    DiffText({ fg = c.red }),
    DiffFile({ fg = c.magenta }),
    diffAdded({ fg = c.green }),
    diffRemoved({ fg = c.red }),
    diffOldFile({ fg = c.red }),
    diffNewFile({ fg = c.green }),

    Normal({ fg = c.fg }),
    Constant({ fg = c.cyan }),
    String({ fg = c.green }),
    Identifier({ fg = c.cyan }),
    Function({ fg = c.magenta, gui = bold }),
    Statement({ fg = c.cyan }),
    Keyword({ fg = c.cyan }),
    PreProc({ fg = c.cyan }),
    Type({ fg = c.yellow, gui = bold }),
    Special({ fg = c.cyan }),
    Error({ fg = c.red, bg = none }),
    Comment({ fg = c.gray3, gui = italic }),
    Todo({ fg = c.bright.magenta, guibg = none, gui = italic }),
    TodoFgNOTE({ fg = c.bright.green, guibg = none, gui = italic }),
    TodoBgNOTE({ fg = c.bright.green, guibg = none, gui = italic }),
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

    sym('@function')({ Function }),
    sym('@method')({ sym('@function') }),

    sym('@conditional')({ fg = c.cyan }),
    sym('@namespace')({ fg = c.cyan }),
    sym('@operator')({ fg = c.cyan }),
    sym('@type')({ Type }),
    sym('@type.builtin')({ sym('@type') }),
    sym('@constructor')({ sym('@type') }),
    sym('@constructor.lua')({ fg = c.fg }),
    sym('@tag')({ fg = c.blue }),
    sym('@tag.delimiter')({ sym('@tag') }),
    sym('@tag.attribute')({ fg = c.blue }),
    sym('@reactHook')({ fg = c.blue }),
    sym('@className')({ fg = c.red }),
    sym('@function.call')({ fg = c.blue }),
    sym('@method.call')({ sym('@function.call') }),
    sym('@function.method.call')({ sym('@function.call') }),

    sym('@markup.link.label.tsx')({ gui = none }),

    -- Vimwiki
    VimWikiLink({ guibg = none, gui = none, fg = c.cyan }),
    VimwikiHr({ fg = c.magenta }),
    VimwikiHeader1({ fg = c.magenta }),
    VimwikiHeader2({ fg = c.magenta }),
    VimwikiList({ Normal }),
    VimwikiCode({ Normal }),

    -- Floaterm
    -- FloatermBorder({ fg = hsl('#1e1f2b') }),

    -- Telescope
    TelescopeMatching({ fg = c.red }),
    TelescopeBorder({ fg = c.cyan }),
    TelescopePromptBorder({ TelescopeBorder }),
    TelescopeResultsBorder({ TelescopeBorder }),
    TelescopePreviewBorder({ TelescopeBorder }),
    TelescopePromptPrefix({ TelescopeBorder }),
    TelescopeSelection({ fg = c.blue }),
    TelescopeSelectionCaret({ fg = c.blue }),
    TelescopeMultiSelection({ fg = c.cyan }),
    TelescopePromptCounter({ fg = c.cyan }),

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
    TreesitterContextLineNumber({ fg = c.yellow }),

    -- Navbuddy
    NavbuddyClass({ fg = c.yellow }),
    NavbuddyModule({ fg = c.yellow }),
    NavbuddyMethod({ fg = c.green }),

    -- cmp
    CmpItemMenu({ fg = c.gray3 }),
    CmpItemKind({ fg = c.gray3 }),

    -- For export usage
    ColorBlack({ fg = c.black }),
    ColorRed({ fg = c.red }),
    ColorGreen({ fg = c.green }),
    ColorYellow({ fg = c.yellow }),
    ColorBlue({ fg = c.blue }),
    ColorMagenta({ fg = c.magenta }),
    ColorCyan({ fg = c.cyan }),
    ColorWhite({ fg = c.white }),
    ColorFg({ fg = c.fg }),
    ColorBg({ fg = c.bg }),
    ColorGray1({ fg = c.gray1 }),
    ColorGray2({ fg = c.gray2 }),
    ColorGray3({ fg = c.gray3 }),
    ColorGray4({ fg = c.gray4 }),
    ColorGray5({ fg = c.gray5 }),
    ColorGray6({ fg = c.gray6 }),
    ColorBrightBlack({ fg = c.bright.black }),
    ColorBrightRed({ fg = c.bright.red }),
    ColorBrightGreen({ fg = c.bright.green }),
    ColorBrightYellow({ fg = c.bright.yellow }),
    ColorBrightBlue({ fg = c.bright.blue }),
    ColorBrightMagenta({ fg = c.bright.magenta }),
    ColorBrightCyan({ fg = c.bright.cyan }),
    ColorBrightWhite({ fg = c.bright.white }),
  }
end)

-- Light theme
-- call s:HL('HopNextKey',  s:wBold, s:wRed)
-- call s:HL('HopNextKey1', s:wBold, s:wcyan)
-- call s:HL('HopNextKey2', s:wBold, s:wMagenta)
-- call s:HL('ColorColumn', 'guibg=#d5d6d7')
-- call s:HL('QuickFixLine', s:wBg2, s:wFg5)
-- call s:HL('Visual', s:wBg5)
-- call s:HL('Search', s:wBg4)
-- hi! Normal ctermbg=NONE guibg=#d5d6d7 guifg=#0c1c2b

return theme
