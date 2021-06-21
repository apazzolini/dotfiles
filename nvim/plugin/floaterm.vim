let g:floaterm_width=0.9
let g:floaterm_height=0.9

nnoremap <c-q> :FloatermToggle<cr>
tnoremap <c-q> <c-\><c-n>:FloatermToggle<cr>
tnoremap <esc><esc> <c-\><c-n>

nnoremap <c-g> :FloatermNew --autoclose=2  lazygit -ucd ~/.config/lazygit<CR>
