vim.g.tmux_navigator_disable_when_zoomed = 1

if vim.env.TMUX == nil then
  -- These get set by tmux-navigator when in tmux
  vim.keymap.set('n', '<c-h>', '<c-w><c-h>')
  vim.keymap.set('n', '<c-j>', '<c-w><c-j>')
  vim.keymap.set('n', '<c-k>', '<c-w><c-k>')
  vim.keymap.set('n', '<c-l>', '<c-w><c-l>')
end

return {
  'apazzolini/vim-tmux-navigator',
  branch = 'indicator',
  cond = function()
    return vim.env.TMUX ~= nil
  end,
}
