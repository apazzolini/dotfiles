if !has('gui_running') && &t_Co < 256
  finish
endif

" hi clear

if exists('syntax_on')
  syntax reset
endif

let s:colors_name = 'wave'

let s:home = has('osx') ? '/Users/andre' : '/home/andre'

if &background ==# 'dark'
  if empty($TMUX)
    hi! Normal ctermbg=NONE ctermfg=7 guibg=#1c2023 guifg=#C4CAD5
  else
    " When we're using vim in tmux, we want the background to be transparent
    " so that the active tmux pane is more readily apparant.
    hi! Normal ctermbg=NONE ctermfg=7 guibg=NONE guifg=#C4CAD5
  endif

  let s:bright = 0
  let s:wRgbBlack         = ''
  let s:wRgbRed           = ''
  let s:wRgbGreen         = ''
  let s:wRgbYellow        = ''
  let s:wRgbBlue          = ''
  let s:wRgbMagenta       = ''
  let s:wRgbCyan          = ''
  let s:wRgbWhite         = ''
  let s:wRgbBrightRed     = ''
  let s:wRgbBrightMagenta = ''
  let s:wRgbBrightCyan    = ''
  let s:wRgb232           = ''
  let s:wRgb244           = ''
  let s:wRgb245           = ''
  let s:wRgb246           = ''
  let s:wRgb247           = ''
  let s:wRgb248           = ''
  let s:wRgb249           = ''

  for line in readfile(s:home .. '/.dotfiles/systems/shared/alacritty.yml')
    if line =~ 'Bright colors'
      let s:bright = 1
    endif

    if line =~ '^\s*#'
      continue
    endif

    if s:bright
      if !len(s:wRgbBrightRed) && line =~ 'red:' | let s:wRgbBrightRed = strpart(line, 14, 7) | endif
      if !len(s:wRgbBrightMagenta) && line =~ 'magenta:' | let s:wRgbBrightMagenta = strpart(line, 14, 7) | endif
      if !len(s:wRgbBrightCyan) && line =~ 'cyan:' | let s:wRgbBrightCyan = strpart(line, 14, 7) | endif
    else
      if !len(s:wRgbBlack) && line =~ 'black:'     | let s:wRgbBlack = strpart(line, 14, 7)   | endif
      if !len(s:wRgbRed) && line =~ 'red:'         | let s:wRgbRed = strpart(line, 14, 7)     | endif
      if !len(s:wRgbGreen) && line =~ 'green:'     | let s:wRgbGreen = strpart(line, 14, 7)   | endif
      if !len(s:wRgbYellow) && line =~ 'yellow:'   | let s:wRgbYellow = strpart(line, 14, 7)  | endif
      if !len(s:wRgbBlue) && line =~ 'blue:'       | let s:wRgbBlue = strpart(line, 14, 7)    | endif
      if !len(s:wRgbMagenta) && line =~ 'magenta:' | let s:wRgbMagenta = strpart(line, 14, 7) | endif
      if !len(s:wRgbCyan) && line =~ 'cyan:'       | let s:wRgbCyan = strpart(line, 14, 7)    | endif
      if !len(s:wRgbWhite) && line =~ 'white:'     | let s:wRgbWhite = strpart(line, 14, 7)   | endif
    endif

    if !len(s:wRgb232) && line =~ 'index: 232' | let s:wRgb232 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb244) && line =~ 'index: 244' | let s:wRgb244 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb245) && line =~ 'index: 245' | let s:wRgb245 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb246) && line =~ 'index: 246' | let s:wRgb246 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb247) && line =~ 'index: 247' | let s:wRgb247 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb248) && line =~ 'index: 248' | let s:wRgb248 = strpart(line, 28, 7)   | endif
    if !len(s:wRgb249) && line =~ 'index: 249' | let s:wRgb249 = strpart(line, 28, 7)   | endif
  endfor

  let s:terminal_color_1 = s:wRgbRed
  let s:terminal_color_2 = s:wRgbGreen
  let s:terminal_color_3 = s:wRgbYellow
  let s:terminal_color_4 = s:wRgbBlue
  let s:terminal_color_5 = s:wRgbMagenta
  let s:terminal_color_6 = s:wRgbCyan
  let s:terminal_color_9 = s:wRgbBrightRed
  let s:terminal_color_13 = s:wRgbBrightMagenta
else
  hi! Normal ctermbg=NONE guibg=#d5d6d7 guifg=#0c1c2b

  let s:wRgbBlack     = '#f7f9fb'
  let s:wRgbRed       = '#bf5656'
  let s:wRgbGreen     = '#5f8539'
  let s:wRgbYellow    = '#bfbf56'
  let s:wRgbBlue      = '#568bbf'
  let s:wRgbMagenta   = '#bf568b'
  let s:wRgbCyan      = '#56bf8b'
  let s:wRgbWhite     = '#0b1c2c'
  let s:wRgbBrightRed = '#bf8b56'
  let s:wRgbBrightMagenta = '#bf568b'
  let s:wRgbBrightCyan = '#bf568b'
  let s:wRgb244       = '#dfe2e5'
  let s:wRgb245       = '#565e65'
  let s:wRgb246       = '#747c84'
  let s:wRgb247       = '#adb3ba'
  let s:wRgb248       = '#c7ccd1'
  let s:wRgb249       = '#2b3034'
endif

" Color definitions
let s:wBlack='ctermfg=0 guifg='.s:wRgbBlack
let s:wRed='ctermfg=1 guifg='.s:wRgbRed
let s:wGreen='ctermfg=2 guifg='.s:wRgbGreen
let s:wYellow='ctermfg=3 guifg='.s:wRgbYellow
let s:wBlue='ctermfg=4 guifg='.s:wRgbBlue
let s:wMagenta='ctermfg=5 guifg='.s:wRgbMagenta
let s:wCyan='ctermfg=6 guifg='.s:wRgbCyan
let s:wWhite='ctermfg=7 guifg='.s:wRgbWhite
let s:wBrightRed='ctermfg=9 guifg='.s:wRgbBrightRed
let s:wBrightMagenta='ctermfg=13 guifg='.s:wRgbBrightMagenta
let s:wBrightCyan='ctermfg=14 guifg='.s:wRgbBrightCyan
let s:wFgTermBg='ctermfg=232 guifg='.s:wRgb232
let s:wFg1='ctermfg=244 guifg='.s:wRgb244
let s:wFg2='ctermfg=245 guifg='.s:wRgb245
let s:wFg3='ctermfg=246 guifg='.s:wRgb246
let s:wFg4='ctermfg=247 guifg='.s:wRgb247
let s:wFg5='ctermfg=248 guifg='.s:wRgb248
let s:wFg6='ctermfg=249 guifg='.s:wRgb249

let s:wBgBlack='ctermbg=0 guibg='.s:wRgbBlack
let s:wBgRed='ctermbg=1 guibg='.s:wRgbRed
let s:wBgGreen='ctermbg=2 guibg='.s:wRgbGreen
let s:wBgYellow='ctermbg=3 guibg='.s:wRgbYellow
let s:wBgBlue='ctermbg=4 guibg='.s:wRgbBlue
let s:wBgMagenta='ctermbg=5 guibg='.s:wRgbMagenta
let s:wBgCyan='ctermbg=6 guibg='.s:wRgbCyan
let s:wBgWhite='ctermbg=7 guibg='.s:wRgbWhite
let s:wBgTermBg='ctermfg=232 guifg='.s:wRgb232
let s:wBg1='ctermbg=244 guibg='.s:wRgb244
let s:wBg2='ctermbg=245 guibg='.s:wRgb245
let s:wBg3='ctermbg=246 guibg='.s:wRgb246
let s:wBg4='ctermbg=247 guibg='.s:wRgb247
let s:wBg5='ctermbg=248 guibg='.s:wRgb248
let s:wBg6='ctermbg=249 guibg='.s:wRgb249

let s:wItalic='cterm=italic gui=italic'
let s:wBold='cterm=bold gui=bold'
let s:wNoBg='ctermbg=none guibg=none'
let s:wNoFg='cterm=none gui=none'

function! s:HL(group, ...)
    let i=0
    let cmd=['hi!', a:group]
    while i < a:0
        call add(cmd, a:000[i])
        let i += 1
    endwhile
    execute join(cmd, ' ')
endfunction

" Search and Selection
if &background ==# 'dark'
  call s:HL('Visual', s:wBg2)
  call s:HL('QuickFixLine', s:wBg2, s:wFg5)
  call s:HL('Search', s:wBg2, s:wWhite)
  hi! link IncSearch Search
else
  call s:HL('Visual', s:wBg5)
  call s:HL('QuickFixLine', s:wBg2, s:wFg5)
  call s:HL('Search', s:wBg4)
  hi! link IncSearch Search
endif

call s:HL('Pmenu', s:wBg1, s:wFg5)
call s:HL('PmenuSel', s:wBgGreen, s:wBlack)

" Diff
call s:HL('diffAdded', s:wGreen)
call s:HL('diffRemoved', s:wRed)
call s:HL('DiffAdd', s:wBgGreen, s:wFg1)
call s:HL('DiffRemove', s:wBgRed, s:wFg1)
call s:HL('DiffChange', s:wMagenta, s:wNoBg)
call s:HL('DiffDelete', s:wBg2, s:wFg1)

" Non-code-related
call s:HL('Comment', s:wFg3, s:wItalic)
call s:HL('Directory', s:wGreen)
call s:HL('SignColumn', s:wNoBg)
call s:HL('Error', s:wRed, s:wNoBg)
call s:HL('ErrorMsg', s:wRed, s:wNoBg)
call s:HL('DiffText', s:wRed)
call s:HL('Question', s:wGreen)
call s:HL('MoreMsg', s:wGreen)
call s:HL('ModeMsg', s:wGreen, s:wNoFg)
call s:HL('MatchParen', s:wMagenta, s:wNoBg)
call s:HL('Title', s:wBlue)
call s:HL('Special', s:wBlue)
call s:HL('SpecialKey', s:wBlue)
call s:HL('NonText', s:wFg1)
call s:HL('VertSplit', s:wNoBg, s:wFg3, s:wNoFg)
call s:HL('CursorLine', s:wBg1, s:wNoFg)
call s:HL('Cursor', s:wNoFg, s:wBgRed, s:wBlack)
call s:HL('Todo', s:wNoBg, s:wRed, s:wItalic)
call s:HL('TabLineSel', s:wBg1, s:wMagenta, s:wNoFg)
call s:HL('TabLineFill', s:wNoBg, s:wNoFg, s:wNoFg)
call s:HL('TabLine', s:wNoBg, s:wFg2, s:wNoFg)
call s:HL('LineNr', s:wFg2)
call s:HL('CursorLineNr', s:wFg4, s:wNoFg)
call s:HL('TreesitterContextLineNumber', s:wGreen)
call s:HL('Folded', s:wNoBg)
call s:HL('qfLineNr', s:wRed)
call s:HL('StatusLine', s:wBg1, s:wNoFg)

if &background ==# 'dark'
  call s:HL('ColorColumn', s:wBg2)
else
  call s:HL('ColorColumn', 'guibg=#d5d6d7')
endif

" Builtin code types
call s:HL('Keyword', s:wBlue)
call s:HL('Statement', s:wBlue)
call s:HL('Constant', s:wBlue)
call s:HL('PreProc', s:wBlue)
call s:HL('Type', s:wBlue)
call s:HL('Identifier', s:wBlue)
call s:HL('Function', s:wMagenta)
call s:HL('String', s:wGreen)

" Tree-sitter code types
call s:HL('@reactHook', s:wCyan)
call s:HL('@className', s:wRed)
call s:HL('@jsxAttribute', s:wGreen)
call s:HL('@function.call', s:wYellow)
call s:HL('@method.call', s:wYellow)
call s:HL('@namespace', s:wBlue)
call s:HL('@conditional', s:wBlue)
call s:HL('@operator', s:wBlue)
call s:HL('@tag', s:wCyan)
call s:HL('@type', s:wCyan, s:wBold)
call s:HL('@type.builtin', s:wCyan, s:wBold)
call s:HL('@function', s:wMagenta, s:wBold)
hi! link @property Normal
hi! link @tag.delimiter TSTag
hi! link @punctuation.delimiter Normal
hi! link @punctuation.bracket Normal
hi! link @punctuation.special Normal
hi! link @constructor Normal
hi! link @parameter Normal
hi! link @constant Normal
hi! link @variable Normal
hi! link @variable.builtin Normal
" These seem to have been unused
" call s:HL('@identifier', s:wMagenta)
" hi! link Whitespace Normal

" VimWiki
call s:HL('VimWikiLink', s:wNoBg, s:wNoFg, s:wBlue)
hi! link VimwikiHr Normal
hi! link VimwikiList Normal
hi! link VimwikiCode Normal

" Floaterm
call s:HL('FloatermBorder', s:wFgTermBg)

" LSP
call s:HL('LspDiagnosticsDefaultError', s:wRed)
call s:HL('DiagnosticError', s:wRed)
call s:HL('DiagnosticWarn', s:wYellow)
hi! link DiagnosticVirtualTextWarn  DiagnosticWarn

" Telescope
call s:HL('TelescopeMatching', s:wRed)
call s:HL('TelescopeBorder', s:wMagenta)
hi! link TelescopePromptBorder  TelescopeBorder
hi! link TelescopeResultsBorder TelescopeBorder
hi! link TelescopePreviewBorder TelescopeBorder
hi! link TelescopePromptPrefix TelescopeBorder
call s:HL('TelescopeSelection', s:wCyan)
hi! link TelescopeSelectionCaret TelescopeSelection
call s:HL('TelescopeMultiSelection', s:wMagenta)
call s:HL('TelescopePromptCounter', s:wMagenta)

" Hop
if &background ==# 'dark'
  " call s:HL('HopNextKey',  s:wBold, 'guifg=#ff007c')
  " call s:HL('HopNextKey1', s:wBold, 'guifg=#00dfff')
  " call s:HL('HopNextKey2', s:wBold, 'guifg=#2b8db3')
  call s:HL('HopNextKey',  s:wBold, s:wBrightMagenta, s:wBg1)
  call s:HL('HopNextKey1', s:wBold, s:wBrightMagenta, s:wBg1)
  call s:HL('HopNextKey2', s:wBold, s:wBrightMagenta, s:wBg1)
else
  call s:HL('HopNextKey',  s:wBold, s:wRed)
  call s:HL('HopNextKey1', s:wBold, s:wBlue)
  call s:HL('HopNextKey2', s:wBold, s:wMagenta)
endif

" Nvim-Tree
call s:HL('NvimTreeExecFile', s:wWhite)
call s:HL('NvimTreeImageFile', s:wWhite)
call s:HL('NvimTreeRootFolder', s:wMagenta)

" VS Code theme colors
" https://www.reddit.com/r/neovim/comments/r42njg/here_are_the_vs_code_theme_colors_for_the_new/
" highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
" highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
" highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
" highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
" highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
" highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
