let g:floaterm_width=0.9
let g:floaterm_height=0.9

nnoremap <c-q> :FloatermToggle<cr>
tnoremap <c-q> <c-\><c-n>:FloatermToggle<cr>
tnoremap <c-]> <c-\><c-n>
tnoremap <c-o> <c-\><c-n><c-o>
tnoremap <a-[> <c-\><c-n>gT
tnoremap <a-]> <c-\><c-n>gt
tnoremap <a-k> <c-l>

nnoremap <c-g> :FloatermNew --autoclose=2  lazygit -ucd ~/.config/lazygit<CR>
