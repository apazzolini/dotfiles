let g:LanguageClient_serverCommands = {
\ 'javascript.jsx': ['/usr/local/bin/javascript-typescript-stdio'],
\ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
\ }

let g:LanguageClient_diagnosticsEnable = 0
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
