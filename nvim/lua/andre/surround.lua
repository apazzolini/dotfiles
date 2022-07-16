if not pcall(require, 'nvim-surround') then
  return
end

require('nvim-surround').setup({
  delimiters = {
    pairs = {
      ['c'] = function()
        return {
          'try {',
          '} catch (e) {}',
        }
      end,
      ['i'] = function()
        return {
          'if () {',
          '}',
        }
      end,
    },
  },
})
