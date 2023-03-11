vim.filetype.add({
  extension = {
    astro = 'astro',
    mdx = 'markdown',
  },
  filename = {},
  pattern = {
    ['.*/zsh/functions/.*'] = 'zsh',
    ['gitconfig.*'] = 'gitconfig',
  },
})
