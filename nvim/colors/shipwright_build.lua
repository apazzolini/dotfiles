---@diagnostic disable: undefined-global, unused-local

local function alacritty(colors)
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

local function ghostty(colors)
  return {
    'background = ' .. colors.ColorBg.fg,
    'foreground = ' .. colors.ColorFg.fg,
    '',
    'palette = 0=' .. colors.ColorBlack.fg,
    'palette = 1=' .. colors.ColorRed.fg,
    'palette = 2=' .. colors.ColorGreen.fg,
    'palette = 3=' .. colors.ColorYellow.fg,
    'palette = 4=' .. colors.ColorBlue.fg,
    'palette = 5=' .. colors.ColorMagenta.fg,
    'palette = 6=' .. colors.ColorCyan.fg,
    'palette = 7=' .. colors.ColorWhite.fg,
    '',
    'palette = 8=' .. colors.ColorBrightBlack.fg,
    'palette = 9=' .. colors.ColorBrightRed.fg,
    'palette = 10=' .. colors.ColorBrightGreen.fg,
    'palette = 11=' .. colors.ColorBrightYellow.fg,
    'palette = 12=' .. colors.ColorBrightBlue.fg,
    'palette = 13=' .. colors.ColorBrightMagenta.fg,
    'palette = 14=' .. colors.ColorBrightCyan.fg,
    'palette = 15=' .. colors.ColorBrightWhite.fg,
    '',
    'palette = 244=' .. colors.ColorGray1.fg,
    'palette = 245=' .. colors.ColorGray2.fg,
    'palette = 246=' .. colors.ColorGray3.fg,
    'palette = 247=' .. colors.ColorGray4.fg,
    'palette = 248=' .. colors.ColorGray5.fg,
    'palette = 249=' .. colors.ColorGray6.fg,
  }
end

package.loaded['plugins.colors.wave'] = nil
run(
  require('plugins.colors.wave'),
  -- generate lua code
  -- wezterm,
  ghostty,
  -- write the lua code into our destination.
  -- you must specify open and close markers yourself to account
  -- for differing comment styles, patchwrite isn't limited to lua files.
  -- { patchwrite, vim.fn.expand('~') .. '/.dotfiles/wezterm/colors.lua', '-- PATCH_OPEN', '-- PATCH_CLOSE' }
  { patchwrite, vim.fn.expand('~') .. '/.dotfiles/systems/osx/ghostty/config', '# PATCH_OPEN', '# PATCH_CLOSE' }
)
