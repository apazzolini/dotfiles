let b:pear_tree_pairs = extend(deepcopy(g:pear_tree_pairs), {
  \ '`'     : {'closer': '`'},
  \ }, 'keep')

set errorformat+=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
