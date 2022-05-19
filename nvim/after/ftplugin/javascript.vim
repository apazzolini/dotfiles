set errorformat+=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m

" Test mappings
nmap <buffer> <leader>ot mT:%s/test.only/test/ge<cr>'T?test(<cr>cetest.only<esc>'T
nmap <buffer> <leader>oa mT?test(<cr>cetest.only<esc>'T
nmap <buffer> <leader>ox mT:%s/test.only/test/ge<cr>'T
