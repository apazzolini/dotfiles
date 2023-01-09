vim.g.tmux_navigator_disable_when_zoomed = 1

return {
  'apazzolini/vim-tmux-navigator',
  branch = 'indicator',
  cond = function()
    return vim.env.TMUX ~= nil
  end,
}
