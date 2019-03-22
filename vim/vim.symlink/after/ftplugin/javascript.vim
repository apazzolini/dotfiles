setlocal signcolumn=yes
setlocal winwidth=88

let g:pairtools_javascript_pairclamp = 1
let g:pairtools_javascript_tagwrench = 1
let g:pairtools_javascript_jigsaw    = 1
let g:pairtools_javascript_autoclose  = 1
let g:pairtools_javascript_forcepairs = 0
let g:pairtools_javascript_closepairs = "(:),[:],{:},':'" . ',":"'
let g:pairtools_javascript_smartclose = 1
let g:pairtools_javascript_smartcloserules = '\w,(,&,\*'
let g:pairtools_javascript_apostrophe = 0
let g:pairtools_javascript_antimagic  = 1
let g:pairtools_javascript_antimagicfield  = "Comment,String,Special"
let g:pairtools_javascript_pcexpander = 1
let g:pairtools_javascript_pceraser   = 1
let g:pairtools_javascript_tagwrenchhook = 'tagwrench#BuiltinHTML5Hook'
let g:pairtools_javascript_twexpander = 1
let g:pairtools_javascript_tweraser   = 0

nmap <silent> [q :call qf#wrap#WrapCommand('up', 'c')<CR>
nmap <silent> ]q :call qf#wrap#WrapCommand('down', 'c')<CR>
