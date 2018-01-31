let g:LanguageClient_serverCommands = {
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'javascript.jsx': ['javascript-typescript-stdio'],
    \ }

let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_autoStart = 1
let g:LanguageClient_windowLogMessageLevel = "Error"
let g:LanguageClient_loggingLevel = "ERROR"
let g:LanguageClient_diagnosticsList = ""

nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
