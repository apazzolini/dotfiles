let g:flow#enable = 0
let g:jsx_ext_required = 0

hi link xmlEndTag xmlTag
hi link jsxCloseTag jsxTag
hi link jsxCloseString jsxTag

let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.js,*.jsx"

nmap gd mT:TernDef<CR>
nmap gb 'T

hi! link jsGlobalObjects GruvboxFg1
hi! link jsGlobalNodeObjects jsGlobalObjects
hi! link jsBuiltins jsGlobalObjects

hi! link jsImport GruvboxBlue
hi! link jsFrom jsImport
hi! link jsExport jsImport
hi! link jsExportDefault jsImport

hi! link jsString GruvboxAqua
hi! link jsTemplateString jsString
hi! link jsObjectStringKey jsString

hi! link jsNumber GruvboxYellow
hi! link jsBooleanTrue jsNumber
hi! link jsBooleanFalse jsNumber

hi! link jsFuncAssignment GruvboxPurple
hi! link jsObjectFuncName jsFuncAssignment

hi! link jsStorageClass GruvboxBlue

hi! link jsKeyword GruvBoxBlue
hi! link jsAsyncKeyword jsKeyword
hi! link jsReturn jsKeyword
hi! link jsConditional jsKeyword
hi! link jsForAwait jsKeyword
hi! link jsTry jsKeyword
hi! link jsCatch jsKeyword
hi! link jsException jsKeyword
hi! link jsFinally jsKeyword
hi! link jsRepeat jsKeyword

" let s:gb.bright_red     = ['#fb4934', 167]     " 251-73-52
" let s:gb.bright_green   = ['#b8bb26', 142]     " 184-187-38
" let s:gb.bright_yellow  = ['#fabd2f', 214]     " 250-189-47
" let s:gb.bright_blue    = ['#83a598', 109]     " 131-165-152
" let s:gb.bright_purple  = ['#d3869b', 175]     " 211-134-155
" let s:gb.bright_aqua    = ['#8ec07c', 108]     " 142-192-124
" let s:gb.bright_orange  = ['#fe8019', 208]     " 254-128-25
