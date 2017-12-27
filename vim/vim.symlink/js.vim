let g:flow#enable = 0
let g:jsx_ext_required = 0

let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.js,*.jsx"

nmap gd mT:TernDef<CR>
nmap gb 'T

"hi! link jsGlobalObjects GruvboxFg1
"hi! link jsGlobalNodeObjects jsGlobalObjects
"hi! link jsBuiltins jsGlobalObjects
"
"hi! link jsImport GruvboxBlue
"hi! link jsFrom jsImport
"hi! link jsExport jsImport
"hi! link jsExportDefault jsImport
"
"hi! link jsString GruvboxAqua
"hi! link jsTemplateString jsString
"hi! link jsObjectStringKey jsString
"
"hi! link jsNumber GruvboxYellow
"hi! link jsBooleanTrue jsNumber
"hi! link jsBooleanFalse jsNumber
"
"hi! link jsFuncAssignment GruvboxPurple
"hi! link jsObjectFuncName jsFuncAssignment
"
"hi! link jsStorageClass GruvboxBlue
"
"hi! link jsKeyword GruvBoxBlue
"hi! link jsAsyncKeyword jsKeyword
"hi! link jsReturn jsKeyword
"hi! link jsConditional jsKeyword
"hi! link jsForAwait jsKeyword
"hi! link jsTry jsKeyword
"hi! link jsCatch jsKeyword
"hi! link jsException jsKeyword
"hi! link jsFinally jsKeyword
"hi! link jsRepeat jsKeyword
"hi! link cssBraces Delimiter
"hi! link cssClassName Special
"
"hi link xmlEndTag xmlTag
"hi link jsxCloseTag jsxTag
"hi link jsxCloseString jsxTag

imap <c-l> <space>=><space>
nmap <leader>re s{<cr>return <esc>l%ls<cr>}<esc>v%=o
nmap <leader>rc dwjds{kLv%S)
