" Maintainer:	Andre Azzolini (apazzolini@gmail.com)
" Last Change:	August 28, 2014
" Colors Used:
" | ------- | ------ | -------------- | ---------------------------- |
" | #2D292B | 2D292B | darkest brown  | background                   |
" | #2E2B2C | 2E2B2C | darker brown   | current line                 |
" | #3F3F3F | 3F3F3F | dark brown     | highlighted line             |
" | #99968C | 99968C | light brown    | comments                     |
" | #DEDACF | DEDACF | lightest brown | text, variables              |
" | ------- | ------ | -------------- | ---------------------------- |
" | #CABDA1 | CABDA1 | medium yellow  | methods                      |
" | #F0E8B7 | F0E8B7 | yellow         | cursor                       |
" | ------- | ------ | -------------- | ---------------------------- |
" | #3EA3B9 | 3EA3B9 | dark blue      | method definition            |
" | #6EB8D2 | 6EB8D2 | blue           | annotations, static fields   |
" | #89D6B1 | 89D6B1 | cyan           | classes                      |
" | #C5ED9C | C5ED9C | green          | keywords                     |
" | ------- | ------ | -------------- | ---------------------------- |
" | #F08080 | F08080 | salmon         | strings, numbers             |
" | #D2CDE8 | D2CDE8 | purple         | javadoc, static fields, task |
" | ------- | ------ | -------------- | ---------------------------- |

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "andre2"

hi CursorLine   guibg=#282526
hi CursorColumn guibg=#2E2B2C
hi MatchParen   guifg=#f6f3e8 guibg=#857b6f gui=bold
hi Pmenu 		guifg=#f6f3e8 guibg=#444444
hi PmenuSel 	guifg=#000000 guibg=#cae682

" General colors
hi Cursor 		guifg=#2D292B guibg=#DEDACF gui=none
hi Normal 		guifg=#DEDACF guibg=#2D292B gui=none
hi NonText 		guifg=#DEDACF guibg=#2D292B gui=none
hi LineNr 		guifg=#99968C guibg=#2D292B gui=none
hi StatusLine 	guifg=#DEDACF guibg=#3F3F3F gui=none
hi StatusLineNC guifg=#DEDACF guibg=#3F3F3F gui=none
hi VertSplit 	guifg=#99968C guibg=#99968C gui=none
hi Folded 		guibg=#99968C guifg=#3F3F3F gui=none
hi Title		guifg=#E8E4D8 guibg=NONE	gui=bold
hi Visual		guifg=#E8E4D8 guibg=#3F3F3F gui=none
hi SpecialKey	guifg=#E8E4D8 guibg=#3F3F3F gui=none
hi Underlined   guifg=#D2CDE8 guibg=NONE    gui=underline


" Syntax highlighting
hi Comment 		guifg=#99968C gui=none
hi Todo 		guifg=#D2CDE8 gui=none
hi Constant 	guifg=#D2CDE8 gui=none
hi String 		guifg=#F08080 gui=none
hi Identifier 	guifg=#F08080 gui=none
hi Function 	guifg=#3EA3B9 gui=none
hi Type 		guifg=#C5ED9C gui=none
hi Statement 	guifg=#C5ED9C gui=none
hi Keyword		guifg=#C5ED9C gui=none
hi PreProc 		guifg=#6EB8D2 gui=none
hi Number		guifg=#F08080 gui=none
hi Special		guifg=#6EB8D2 gui=none
hi Directory    guifg=#89D6B1 gui=none

" Html highlighting
hi HtmlTag guifg=#DEDACF gui=none
hi HtmlEndTag guifg=#DEDACF gui=none
hi HtmlTagN guifg=#89D6B1 gui=none
hi HtmlTagName guifg=#89D6B1 gui=none
hi HtmlSpecialTagName guifg=#89D6B1 gui=none
hi HtmlArg guifg=#F08080 gui=none

"exe "hi! htmlTag"           .s:fmt_none .s:fg_base01 .s:bg_none
"exe "hi! htmlEndTag"        .s:fmt_none .s:fg_base01 .s:bg_none
"exe "hi! htmlTagN"          .s:fmt_bold .s:fg_base1  .s:bg_none
"exe "hi! htmlTagName"       .s:fmt_bold .s:fg_blue   .s:bg_none
"exe "hi! htmlSpecialTagName".s:fmt_ital .s:fg_blue   .s:bg_none
"exe "hi! htmlArg"           .s:fmt_none .s:fg_base00 .s:bg_none
"exe "hi! javaScript"        .s:fmt_none .s:fg_yellow .s:bg_none

"
"
"let ColourAssignment['GlobalVariable']  = {"GUIFG": '#666600',     "CTERMFG": 'Cyan',      "TERM":  'Underline'}
"let ColourAssignment['LocalVariable']   = {"GUIFG": '#aaa14c',     "CTERMFG": 'Cyan'}
"let ColourAssignment['GlobalConstant']  = {"GUIFG": '#bbbb00',     "CTERMFG": 'Yellow',      "TERM":  'Underline'}

" Types/storage classes etc are shades of orangey-red


