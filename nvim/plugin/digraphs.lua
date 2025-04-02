vim.cmd([[
  dig '' 8217
  dig \"\" 8220
  dig \"' 8221

  iabbrev <expr> dtt strftime("%D %H:%M:%S:")
]])
