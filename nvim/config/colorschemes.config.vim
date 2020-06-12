" https://github.com/flazz/vim-colorschemes

" For Neovim 0.1.3 and 0.1.4 - https://github.com/neovim/neovim/pull/2198
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

" For Neovim > 0.1.5 and Vim > patch 7.4.1799 - https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162
" Based on Vim patch 7.4.1770 (`guicolors` option) - https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd
" https://github.com/neovim/neovim/wiki/Following-HEAD#20160511
if (has('termguicolors'))
  set termguicolors
endif

" use theme
""" colorscheme gruvbox
""" colorscheme molokai
""" colorscheme wombat
""" colorscheme solarized
""" colorscheme ir_black
""" colorscheme material

" vim-material themes
"" Dark
""" set background=dark
""" colorscheme vim-material

"" Palenight
""" let g:material_style='palenight'
""" set background=dark
""" colorscheme vim-material

"" Oceanic
let g:material_style='oceanic'
set background=dark
colorscheme vim-material

"" Light
""" set background=light
""" colorscheme vim-material

let g:airline_theme='material'

"" highligt search if colorscheme does not well such as 'ir_black'
hi Search guibg=peru guifg=wheat