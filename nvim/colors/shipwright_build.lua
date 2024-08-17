---@diagnostic disable: undefined-global, unused-local

local function wezterm(colors)
  return {
    "    foreground = '" .. colors.ColorFg.fg .. "',",
    "    background = '" .. colors.ColorBg.fg .. "',",
    '',
    '    ansi = {',
    "      '" .. colors.ColorBlack.fg .. "',",
    "      '" .. colors.ColorRed.fg .. "',",
    "      '" .. colors.ColorGreen.fg .. "',",
    "      '" .. colors.ColorYellow.fg .. "',",
    "      '" .. colors.ColorBlue.fg .. "',",
    "      '" .. colors.ColorMagenta.fg .. "',",
    "      '" .. colors.ColorCyan.fg .. "',",
    "      '" .. colors.ColorWhite.fg .. "',",
    '    },',
    '    brights = {',
    "      '" .. colors.ColorBrightBlack.fg .. "',",
    "      '" .. colors.ColorBrightRed.fg .. "',",
    "      '" .. colors.ColorBrightGreen.fg .. "',",
    "      '" .. colors.ColorBrightYellow.fg .. "',",
    "      '" .. colors.ColorBrightBlue.fg .. "',",
    "      '" .. colors.ColorBrightMagenta.fg .. "',",
    "      '" .. colors.ColorBrightCyan.fg .. "',",
    "      '" .. colors.ColorBrightWhite.fg .. "',",
    '    },',
    '    indexed = {',
    "      [244] = '" .. colors.ColorGray1.fg .. "',",
    "      [245] = '" .. colors.ColorGray2.fg .. "',",
    "      [246] = '" .. colors.ColorGray3.fg .. "',",
    "      [247] = '" .. colors.ColorGray4.fg .. "',",
    "      [248] = '" .. colors.ColorGray5.fg .. "',",
    "      [249] = '" .. colors.ColorGray6.fg .. "',",
    '    },',
  }
end

local function alacritty(colors)
  -- return {
  -- indexed_colors = [
  --   { index = 244, color = '#232539' },
  --   { index = 245, color = '#3e415b' },
  --   { index = 246, color = '#6c7086' },
  --   { index = 247, color = '#7f849c' },
  --   { index = 248, color = '#9399b2' },
  --   { index = 249, color = '#a6adc8' },
  -- ]
  --
  -- [colors.primary]
  -- background = "#1c1e2b"
  -- foreground = "#CDD6F4"
  --
  -- [colors.normal]
  -- black = "#1e2027"
  -- red = "#FF87A5"
  -- green = "#b3d1b7"
  -- yellow = "#f2cdcd"
  -- blue = "#BFA4F0"
  -- magenta = "#B98AFF"
  -- cyan = "#E4BBE4"
  -- white = "#c4cad5"
  --
  -- [colors.bright]
  -- black = "#5b6078"
  -- red = "#FF5370"
  -- green = "#1bfd9c"
  -- yellow = "#f9e2af"
  -- blue = "#B68EDB"
  -- magenta = "#ff007c"
  -- cyan = "#87CFD1"
  -- white = "#A0A5C2"
  -- }

  return {
    'indexed_colors = [',
    '  { index = 244, color = "' .. colors.ColorGray1.fg .. '"},',
    '  { index = 245, color = "' .. colors.ColorGray2.fg .. '"},',
    '  { index = 246, color = "' .. colors.ColorGray3.fg .. '"},',
    '  { index = 247, color = "' .. colors.ColorGray4.fg .. '"},',
    '  { index = 248, color = "' .. colors.ColorGray5.fg .. '"},',
    '  { index = 249, color = "' .. colors.ColorGray6.fg .. '"},',
    ']',
    '',
    '[colors.primary]',
    "foreground = '" .. colors.ColorFg.fg .. "'",
    "background = '" .. colors.ColorBg.fg .. "'",
    '',
    '[colors.normal]',
    'black = "' .. colors.ColorBlack.fg .. '"',
    'red = "' .. colors.ColorRed.fg .. '"',
    'green = "' .. colors.ColorGreen.fg .. '"',
    'yellow = "' .. colors.ColorYellow.fg .. '"',
    'blue = "' .. colors.ColorBlue.fg .. '"',
    'magenta = "' .. colors.ColorMagenta.fg .. '"',
    'cyan = "' .. colors.ColorCyan.fg .. '"',
    'white = "' .. colors.ColorWhite.fg .. '"',
    '',
    '[colors.bright]',
    'black = "' .. colors.ColorBrightBlack.fg .. '"',
    'red = "' .. colors.ColorBrightRed.fg .. '"',
    'green = "' .. colors.ColorBrightGreen.fg .. '"',
    'yellow = "' .. colors.ColorBrightYellow.fg .. '"',
    'blue = "' .. colors.ColorBrightBlue.fg .. '"',
    'magenta = "' .. colors.ColorBrightMagenta.fg .. '"',
    'cyan = "' .. colors.ColorBrightCyan.fg .. '"',
    'white = "' .. colors.ColorBrightWhite.fg .. '"',
  }
end

package.loaded['plugins.colors.wave'] = nil
run(
  require('plugins.colors.wave'),
  -- generate lua code
  -- wezterm,
  alacritty,
  -- write the lua code into our destination.
  -- you must specify open and close markers yourself to account
  -- for differing comment styles, patchwrite isn't limited to lua files.
  -- { patchwrite, vim.fn.expand('~') .. '/.dotfiles/wezterm/colors.lua', '-- PATCH_OPEN', '-- PATCH_CLOSE' }
  { patchwrite, vim.fn.expand('~') .. '/.dotfiles/systems/shared/alacritty.toml', '# PATCH_OPEN', '# PATCH_CLOSE' }
)
