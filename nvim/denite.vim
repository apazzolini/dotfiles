call denite#custom#var('file_rec', 'command',
	\ ['ag', '--follow', '--nocolor', '--nogroup', '--hidden', '-g', ''])

call denite#custom#map('insert', '<C-j>', 'move_to_next_line')
call denite#custom#map('insert', '<C-k>', 'move_to_prev_line')

nnoremap <leader>e :Denite file_rec<CR>
nnoremap <leader>t :Denite -default-action=tabopen file_rec<CR>
