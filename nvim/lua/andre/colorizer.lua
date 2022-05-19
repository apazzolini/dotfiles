if not pcall(require, 'colorizer') then
  return
end

require('colorizer').setup({ '*' }, { mode = 'background' })
