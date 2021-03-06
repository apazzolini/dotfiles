if !has('gui_running') && &t_Co < 256
  finish
endif

"hi clear

if exists('syntax_on')
  syntax reset
endif

let s:colors_name = 'wave'

if &background ==# 'dark'
  if empty($TMUX)
    hi! Normal ctermbg=NONE guibg=#1c2023 guifg=#c7ccd1
  else
    " When we're using vim in tmux, we want the background to be transparent
    " so that the active tmux pane is more readily apparant.
    hi! Normal ctermbg=NONE guibg=NONE guifg=#c7ccd1
  endif

  let s:bright = 0
  let s:wRgbBlack     = ''
  let s:wRgbRed       = ''
  let s:wRgbGreen     = ''
  let s:wRgbYellow    = '' " Previously was #E7DDBB
  let s:wRgbBlue      = ''
  let s:wRgbMagenta   = ''
  let s:wRgbCyan      = ''
  let s:wRgbWhite     = ''
  let s:wRgbBrightRed = ''
  let s:wRgb18        = ''
  let s:wRgb244       = ''
  let s:wRgb245       = ''
  let s:wRgb246       = ''
  let s:wRgb247       = ''
  let s:wRgb248       = ''
  let s:wRgb249       = ''

  for line in readfile(g:home .. '/.dotfiles/systems/shared/alacritty.yml')
    if line =~ 'Bright colors'
      let s:bright = 1
    endif

    if s:bright
      if !len(s:wRgbBrightRed) && line =~ 'red' | let s:wRgbBrightRed = strpart(line, 14, 7) | endif
    else
      if !len(s:wRgbBlack) && line =~ 'black'     | let s:wRgbBlack = strpart(line, 14, 7)   | endif
      if !len(s:wRgbRed) && line =~ 'red'         | let s:wRgbRed = strpart(line, 14, 7)     | endif
      if !len(s:wRgbGreen) && line =~ 'green'     | let s:wRgbGreen = strpart(line, 14, 7)   | endif
      if !len(s:wRgbYellow) && line =~ 'yellow'   | let s:wRgbYellow = strpart(line, 14, 7)  | endif
      if !len(s:wRgbBlue) && line =~ 'blue'       | let s:wRgbBlue = strpart(line, 14, 7)    | endif
      if !len(s:wRgbMagenta) && line =~ 'magenta' | let s:wRgbMagenta = strpart(line, 14, 7) | endif
      if !len(s:wRgbCyan) && line =~ 'cyan'       | let s:wRgbCyan = strpart(line, 14, 7)    | endif
      if !len(s:wRgbWhite) && line =~ 'white'     | let s:wRgbWhite = strpart(line, 14, 7)   | endif
    endif

    if !len(s:wRgb18) && line =~ 'index: 18'   | let s:wRgb18 = strpart(line, 28, 7)    | endif
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
  let s:wRgb244       = '#dfe2e5'
  let s:wRgb18        = '#565e65'
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
let s:wFg1='ctermfg=244 guifg='.s:wRgb244
let s:wFg2='ctermfg=245 guifg='.s:wRgb245
let s:wFg3='ctermfg=246 guifg='.s:wRgb246
let s:wFg4='ctermfg=247 guifg='.s:wRgb247
let s:wFg5='ctermfg=248 guifg='.s:wRgb248
let s:wFg6='ctermfg=249 guifg='.s:wRgb249

let s:wBlackBg='ctermbg=0 guibg='.s:wRgbBlack
let s:wRedBg='ctermbg=1 guibg='.s:wRgbRed
let s:wGreenBg='ctermbg=2 guibg='.s:wRgbGreen
let s:wYellowBg='ctermbg=3 guibg='.s:wRgbYellow
let s:wBlueBg='ctermbg=4 guibg='.s:wRgbBlue
let s:wMagentaBg='ctermbg=5 guibg='.s:wRgbMagenta
let s:wCyanBg='ctermbg=6 guibg='.s:wRgbCyan
let s:wWhiteBg='ctermbg=7 guibg='.s:wRgbWhite
let s:wBg0='ctermbg=18 guibg='.s:wRgb18
let s:wBg1='ctermbg=244 guibg='.s:wRgb244
let s:wBg2='ctermbg=245 guibg='.s:wRgb245
let s:wBg3='ctermbg=246 guibg='.s:wRgb246
let s:wBg4='ctermbg=247 guibg='.s:wRgb247
let s:wBg5='ctermbg=248 guibg='.s:wRgb248
let s:wBg6='ctermbg=249 guibg='.s:wRgb249

let s:wItalic='cterm=italic gui=italic'
let s:wNoBg='ctermbg=none guibg=none'
let s:wNoFg='ctermbg=none guibg=none'
let s:wNoCterm='cterm=none gui=none'

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
call s:HL('PmenuSel', s:wGreenBg, s:wBlack)

" Diff
call s:HL('diffAdded', s:wGreen)
call s:HL('diffRemoved', s:wRed)

" Non-code-related
call s:HL('Directory', s:wGreen)
call s:HL('Comment', s:wFg3, s:wItalic)
call s:HL('Directory', s:wGreen)
call s:HL('SignColumn', s:wNoBg)
call s:HL('Error', s:wRed, s:wNoBg)
call s:HL('ErrorMsg', s:wRed, s:wNoBg)
call s:HL('DiffText', s:wRed)
call s:HL('Question', s:wGreen)
call s:HL('MoreMsg', s:wGreen)
call s:HL('ModeMsg', s:wGreen, s:wNoCterm)
call s:HL('MatchParen', s:wMagenta, s:wNoBg)
call s:HL('Title', s:wBlue)
call s:HL('Special', s:wBlue)
call s:HL('SpecialKey', s:wBlue)
call s:HL('NonText', s:wFg1)
call s:HL('VertSplit', s:wNoBg, s:wFg3, s:wNoCterm)
call s:HL('CursorLine', s:wBg0, s:wNoCterm)
call s:HL('Cursor', s:wNoCterm, s:wRedBg, s:wBlack)
call s:HL('Todo', s:wNoBg, s:wRed, s:wItalic)
call s:HL('TabLineSel', s:wBg1, s:wGreen, s:wNoCterm)
call s:HL('TabLineFill', s:wNoBg, s:wNoFg, s:wNoCterm)
call s:HL('TabLine', s:wNoBg, s:wFg2, s:wNoCterm)
call s:HL('LineNr', s:wFg2)
call s:HL('CursorLineNr', s:wFg4)
call s:HL('Folded', s:wNoBg)
call s:HL('qfLineNr', s:wRed)
call s:HL('StatusLine', s:wBg1, s:wNoCterm)

if &background ==# 'dark'
  call s:HL('ColorColumn', s:wBg1)
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
hi! link TSProperty Normal
call s:HL('TS_C_ReactHook', s:wCyan)
call s:HL('TS_C_ClassName', s:wRed)
call s:HL('TS_C_JsxAttribute', s:wGreen)
call s:HL('TS_C_FunctionCall', s:wYellow)
call s:HL('TSNamespace', s:wBlue)
call s:HL('TSConditional', s:wBlue)
call s:HL('TSOperator', s:wBlue)
call s:HL('TSIdentifier', s:wMagenta)
call s:HL('TSTag', s:wCyan)
call s:HL('TSType', s:wCyan, 'gui=bold')
call s:HL('TSTypeBuiltin', s:wCyan, 'gui=bold')
hi! link TSTagDelimiter TSTag
hi! link Whitespace Normal
hi! link TSPunctDelimiter Normal
hi! link TSPunctBracket Normal
hi! link TSPunctSpecial Normal
hi! link TSConstructor Normal
hi! link TSParameter Normal
hi! link TSConstant Normal
hi! link TSVariable Normal
hi! link TSVariableBuiltin Normal

" VimWiki
call s:HL('VimWikiLink', s:wNoBg, s:wNoCterm, s:wBlue)
call s:HL('VimWikiHr', s:wNoBg, s:wNoCterm, s:wNoFg)
hi! link VimwikiList Normal
hi! link VimwikiCode Normal

" LSP
call s:HL('LspDiagnosticsDefaultError', s:wRed)

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

" Hop
if &background ==# 'dark'
  call s:HL('HopNextKey', 'gui=bold', 'guifg=#ff007c')
  call s:HL('HopNextKey1', 'gui=bold', 'guifg=#00dfff')
  call s:HL('HopNextKey2', 'gui=bold', 'guifg=#2b8db3')
else
  call s:HL('HopNextKey', 'gui=bold', s:wRed)
  call s:HL('HopNextKey1', 'gui=bold', s:wBlue)
  call s:HL('HopNextKey2', 'gui=bold', s:wMagenta)
endif

" Nvim-Tree
call s:HL('NvimTreeExecFile', s:wWhite)
call s:HL('NvimTreeImageFile', s:wWhite)
call s:HL('NvimTreeRootFolder', s:wMagenta)
