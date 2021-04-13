if !has('gui_running') && &t_Co < 256
  finish
endif

"hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'wave'

if &background ==# 'dark'
  if empty($TMUX)
    hi! Normal ctermbg=NONE guibg=#1c2023 guifg=#c7ccd1
  else
    " When we're using vim in tmux, we want the background to be transparent
    " so that the active tmux pane is more readily apparant.
    hi! Normal ctermbg=NONE guibg=NONE guifg=#c7ccd1
  endif

  let g:wRgbBlack     = '#1c2023'
  let g:wRgbRed       = '#D5869E'
  let g:wRgbGreen     = '#a2c7a9'
  let g:wRgbYellow    = '#EFE7CA' " Previously was #E7DDBB
  let g:wRgbBlue      = '#95aec7'
  let g:wRgbMagenta   = '#ae95c7'
  let g:wRgbCyan      = '#68b2c9'
  let g:wRgbWhite     = '#c7ccd1'
  let g:wRgbBrightRed = '#d19b9b'
  let g:wRgb244       = '#2b3034'
  let g:wRgb245       = '#565e65'
  let g:wRgb246       = '#747c84'
  let g:wRgb247       = '#adb3ba'
  let g:wRgb248       = '#c7ccd1'
  let g:wRgb249       = '#dfe2e5'
else
  hi! Normal ctermbg=NONE guibg=#d5d6d7 guifg=#0c1c2b

  let g:wRgbBlack     = '#f7f9fb'
  let g:wRgbRed       = '#bf5656'
  let g:wRgbGreen     = '#5f8539'
  let g:wRgbYellow    = '#bfbf56'
  let g:wRgbBlue      = '#568bbf'
  let g:wRgbMagenta   = '#bf568b'
  let g:wRgbCyan      = '#56bf8b'
  let g:wRgbWhite     = '#0b1c2c'
  let g:wRgbBrightRed = '#bf8b56'
  let g:wRgb244       = '#dfe2e5'
  let g:wRgb245       = '#565e65'
  let g:wRgb246       = '#747c84'
  let g:wRgb247       = '#adb3ba'
  let g:wRgb248       = '#c7ccd1'
  let g:wRgb249       = '#2b3034'
endif

" Color definitions
let g:wBlack='ctermfg=0 guifg='.g:wRgbBlack
let g:wRed='ctermfg=1 guifg='.g:wRgbRed
let g:wGreen='ctermfg=2 guifg='.g:wRgbGreen
let g:wYellow='ctermfg=3 guifg='.g:wRgbYellow
let g:wBlue='ctermfg=4 guifg='.g:wRgbBlue
let g:wMagenta='ctermfg=5 guifg='.g:wRgbMagenta
let g:wCyan='ctermfg=6 guifg='.g:wRgbCyan
let g:wWhite='ctermfg=7 guifg='.g:wRgbWhite
let g:wBrightRed='ctermfg=9 guifg='.g:wRgbBrightRed
let g:wFg1='ctermfg=244 guifg='.g:wRgb244
let g:wFg2='ctermfg=245 guifg='.g:wRgb245
let g:wFg3='ctermfg=246 guifg='.g:wRgb246
let g:wFg4='ctermfg=247 guifg='.g:wRgb247
let g:wFg5='ctermfg=248 guifg='.g:wRgb248
let g:wFg6='ctermfg=249 guifg='.g:wRgb249

let g:wBlackBg='ctermbg=0 guibg='.g:wRgbBlack
let g:wRedBg='ctermbg=1 guibg='.g:wRgbRed
let g:wGreenBg='ctermbg=2 guibg='.g:wRgbGreen
let g:wYellowBg='ctermbg=3 guibg='.g:wRgbYellow
let g:wBlueBg='ctermbg=4 guibg='.g:wRgbBlue
let g:wMagentaBg='ctermbg=5 guibg='.g:wRgbMagenta
let g:wCyanBg='ctermbg=6 guibg='.g:wRgbCyan
let g:wWhiteFg='ctermbg=7 guibg='.g:wRgbWhite
let g:wBg1='ctermbg=244 guibg='.g:wRgb244
let g:wBg2='ctermbg=245 guibg='.g:wRgb245
let g:wBg3='ctermbg=246 guibg='.g:wRgb246
let g:wBg4='ctermbg=247 guibg='.g:wRgb247
let g:wBg5='ctermbg=248 guibg='.g:wRgb248
let g:wBg6='ctermbg=249 guibg='.g:wRgb249

let g:wItalic='cterm=italic gui=italic'
let g:wNoBg='ctermbg=none guibg=none'
let g:wNoFg='ctermbg=none guibg=none'
let g:wNoCterm='cterm=none gui=none'

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
  call s:HL('Visual', g:wBg2)
  call s:HL('QuickFixLine', g:wBg2, g:wFg5)
  call s:HL('Search', g:wBg2, g:wWhite)
  hi! link IncSearch Search
else
  call s:HL('Visual', g:wBg5)
  call s:HL('QuickFixLine', g:wBg2, g:wFg5)
  call s:HL('Search', g:wBg4)
  hi! link IncSearch Search
endif

call s:HL('Pmenu', g:wBg2, g:wFg5)
call s:HL('PmenuSel', g:wBg1, g:wFg5)

" Diff
call s:HL('diffAdded', g:wGreen)
call s:HL('diffRemoved', g:wRed)

" Non-code-related
call s:HL('ColorColumn', g:wBg1)
call s:HL('Directory', g:wGreen)
call s:HL('Comment', g:wFg3, g:wItalic)
call s:HL('Directory', g:wGreen)
call s:HL('SignColumn', g:wNoBg)
call s:HL('Error', g:wRed, g:wNoBg)
call s:HL('ErrorMsg', g:wRed, g:wNoBg)
call s:HL('DiffText', g:wRed)
call s:HL('Question', g:wGreen)
call s:HL('MoreMsg', g:wGreen)
call s:HL('ModeMsg', g:wGreen, g:wNoCterm)
call s:HL('MatchParen', g:wBlue, g:wNoBg)
call s:HL('Title', g:wBlue)
call s:HL('Special', g:wBlue)
call s:HL('SpecialKey', g:wBlue)
call s:HL('NonText', g:wFg1)
call s:HL('VertSplit', g:wNoBg, g:wFg3, g:wNoCterm)
call s:HL('CursorLine', g:wBg1, g:wNoCterm)
call s:HL('Cursor', g:wNoCterm, g:wRedBg, g:wBlack)
call s:HL('Todo', g:wNoBg, g:wRed, g:wItalic)
call s:HL('TabLineSel', g:wBg1, g:wGreen, g:wNoCterm)
call s:HL('TabLineFill', g:wNoBg, g:wNoFg, g:wNoCterm)
call s:HL('TabLine', g:wNoBg, g:wFg2, g:wNoCterm)
call s:HL('LineNr', g:wFg2)
call s:HL('CursorLineNr', g:wFg4)
call s:HL('Folded', g:wNoBg)
call s:HL('qfLineNr', g:wRed)

" Builtin code types
call s:HL('Keyword', g:wBlue)
call s:HL('Statement', g:wBlue)
call s:HL('Constant', g:wBlue)
call s:HL('PreProc', g:wBlue)
call s:HL('Type', g:wBlue)
call s:HL('Identifier', g:wBlue)
call s:HL('Function', g:wMagenta)
call s:HL('String', g:wGreen)

" Tree-sitter code types
hi! link TSProperty Normal
call s:HL('TS_C_ReactHook', g:wCyan)
call s:HL('TS_C_ClassName', g:wRed)
call s:HL('TS_C_JsxAttribute', g:wGreen)
call s:HL('TS_C_FunctionCall', g:wYellow)
call s:HL('TSNamespace', g:wBlue)
call s:HL('TSConditional', g:wBlue)
call s:HL('TSOperator', g:wBlue)
call s:HL('TSIdentifier', g:wMagenta)
call s:HL('TSTag', g:wCyan)
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
call s:HL('VimWikiLink', g:wNoBg, g:wNoCterm, g:wBlue)
call s:HL('VimWikiHr', g:wNoBg, g:wNoCterm, g:wNoFg)
hi! link VimwikiList Normal
hi! link VimwikiCode Normal

" LSP
call s:HL('LspDiagnosticsDefaultError', g:wRed)

" Telescope
call s:HL('TelescopeMatching', g:wRed)
call s:HL('TelescopeBorder', 'guifg=#bf568b')
hi! link TelescopePromptBorder  TelescopeBorder
hi! link TelescopeResultsBorder TelescopeBorder
hi! link TelescopePreviewBorder TelescopeBorder
hi! link TelescopePromptPrefix TelescopeBorder
call s:HL('TelescopeSelection', g:wCyan)
hi! link TelescopeSelectionCaret TelescopeSelection
call s:HL('TelescopeMultiSelection', g:wMagenta)

" Galaxyline
highlight! StatusLine gui=none guibg=#2b3034 guifg=NONE
highlight! StatusLineNC gui=underline guibg=#2b3034 guifg=#2b3034
