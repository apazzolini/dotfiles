if not pcall(require, 'colorizer') then
  return
end

require('colorizer').setup(nil, { mode = 'background', rgb_fn = true })
