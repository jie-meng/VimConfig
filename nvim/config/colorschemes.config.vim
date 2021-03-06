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
colorscheme gruvbox
""" colorscheme codedark
""" colorscheme ir_black
""" colorscheme molokai
""" colorscheme monokai 
""" colorscheme wombat

"" colorscheme override
""" hi Search guibg=peru guifg=wheat
""" hi CursorLine term=bold cterm=bold guibg=Grey20
""" hi CursorColumn term=bold cterm=bold guibg=Grey20

"" popup menu override
""" https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax/
""" https://vi.stackexchange.com/questions/12664/is-there-any-way-to-change-the-popup-menu-color
""" :highlight Pmenu ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuSel ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuSbar ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuThumb ctermbg=DarkMagenta guibg=DarkMagenta