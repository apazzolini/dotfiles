" let g:nvim_tree_root_folder_modifier = ':~'
" let g:nvim_tree_add_trailing = 1
" let g:nvim_tree_lsp_diagnostics = 1
let g:nvim_tree_quit_on_open = 1
let g:nvim_tree_width = 30
let g:nvim_tree_ignore = [ '.git', 'node_modules', 'bower_components', '.DS_Store' ]
let g:nvim_tree_hide_dotfiles = 1
let g:nvim_tree_highlight_opened_files = 1
let g:nvim_tree_disable_window_picker = 1
let g:nvim_tree_special_files = []
let g:nvim_tree_show_icons = {
    \ 'git': 0,
    \ 'folders': 1,
    \ 'files': 1,
    \ }

let g:nvim_tree_icons = {
    \ 'default': ' ',
    \ 'folder': {
    \   'default': "▸",
    \   'open': "▾",
    \   },
    \ }

nnoremap <leader>no :let g:nvim_tree_quit_on_open=!g:nvim_tree_quit_on_open<cr>
nnoremap <leader>g :NvimTreeFindFile<CR>
