vim.g.mapleader = ','
vim.g.isNotes = vim.env.IS_NOTES == '1' or (vim.fn.argc() >= 1 and vim.fn.argv()[1]:match('index.md$') ~= nil)

vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.shiftround = true

vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.colorcolumn = ''

vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.updatetime = 200
vim.opt.shortmess:append('c')
vim.opt.secure = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.wrap = true
vim.opt.splitright = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.lazyredraw = false
vim.opt.showcmd = false
vim.opt.switchbuf = 'useopen'
vim.opt.modeline = false
vim.opt.mouse = 'a'
vim.opt.inccommand = 'split'
vim.opt.completeopt = 'menuone,noselect'
vim.opt.pumheight = 20

vim.opt.joinspaces = false

vim.opt.foldmethod = 'manual'
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.foldnestmax = 4

vim.b.javascript_fold = 0
vim.g.javascript_plugin_jsdoc = 1
vim.g.jsx_ext_required = 0

vim.opt.breakindent = true
vim.opt.breakindentopt = 'shift:2'
vim.opt.showbreak = '\\\\'

vim.opt.nrformats = ''
