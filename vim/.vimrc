call plug#begin('~/.vim/plugged')

" window
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'xolox/vim-misc'

" search
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'

" edit
Plug 'skwp/greplace.vim'
Plug 'arthurxavierx/vim-caser'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'

" color
Plug 'flazz/vim-colorschemes'

" complete
Plug 'raimondi/delimitmate'
Plug 'vim-scripts/AutoComplPop'
Plug 'ervandew/supertab'
Plug 'honza/vim-snippets'
" Plug 'sirver/ultisnips'
Plug 'davidhalter/jedi-vim'

" language
Plug 'sheerun/vim-polyglot'
Plug 'moll/vim-node'
Plug 'kannokanno/previm'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'ap/vim-css-color'
Plug 'hail2u/vim-css3-syntax'
Plug 'vim-scripts/a.vim'

" tools
Plug 'w0rp/ale'
Plug 'will133/vim-dirdiff'

" lint
Plug 'scrooloose/syntastic'

call plug#end()

" global 
filetype on
syntax on 

set nu
set nowrap
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set bg=dark
set hlsearch
set nocompatible
set backspace=indent,eol,start
set smartindent
""" set ignorecase

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

"" color
""" colorscheme gruvbox
colorscheme codedark
""" colorscheme ir_black
""" colorscheme molokai
""" colorscheme monokai
""" colorscheme wombat

"" colorscheme override
""" hi Search guibg=peru guifg=wheat
hi CursorLine term=bold cterm=bold guibg=Grey20
hi CursorColumn term=bold cterm=bold guibg=Grey20

"" popup menu override
""" https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax/
""" https://vi.stackexchange.com/questions/12664/is-there-any-way-to-change-the-popup-menu-color
""" :highlight Pmenu ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuSel ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuSbar ctermbg=DarkMagenta guibg=DarkMagenta
""" :highlight PmenuThumb ctermbg=DarkMagenta guibg=DarkMagenta

"" remap C-p to C-i, because C-i sometimes override by other shortcuts
nnoremap <C-p> <C-i>

"" filetype extension 
"" java
au BufNewFile,BufRead *.java,*.jav,*.aidl setf java

"" quick edit vimrc
map <Leader><F2> :e ~/.vimrc<CR>

"" change buffer
map <Leader>[ :bp<Enter>
map <Leader>] :bn<Enter>

"" Disable swap
set noswapfile

"" enable clipboard 
:inoremap <C-v> <ESC>"+pa
:vnoremap <C-c> "+y
:vnoremap<C-d> "+d

"" move
nnoremap mb ^
nnoremap me $
vnoremap mb ^
vnoremap me $

"" Alt + * move line
"" http://vim.wikia.com/wiki/Moving_lines_up_or_down
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

"" tab spaces
set tabstop=4
set expandtab
set shiftwidth=4

"" font
if has('macunix')
    set guifont=Monaco:h12
elseif has('unix')
    set guifont="Ubuntu Mono" 12
endif

"" resize window
map <Leader>= :vertical resize +10<Enter>
map <Leader>- :vertical resize -10<Enter>
map <Leader>. :resize +10<Enter>
map <Leader>, :resize -10<Enter>

"" hightline current line and column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

" scrooloose/nerdtree
"" open a NERDTree automatically when vim starts up
autocmd vimenter * NERDTree | wincmd p
"" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " close vim if the only window left open is a NERDTree
"" open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1 
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif 
"" open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"" toggle tree
map <Leader>w :NERDTreeToggle<Enter>
"" locate current file in the tree
nnoremap <silent> <space>j :NERDTreeFind<Enter>
""" autocmd BufWinEnter * NERDTreeFind
"" folder icon
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

"" search dir
let g:NERDTreeChDirMode = 2
"" startup cursor in editing area
autocmd VimEnter * NERDTree | wincmd p

" vim-fugitive'
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gm :Gmove<CR>
nnoremap <Leader>gd :Gdelete<CR>

" fzf
set rtp+=/usr/local/opt/fzf

"""nnoremap <Leader>ff :Files<CR>
"""nnoremap <Leader>fg :GFiles<CR>
"""nnoremap <Leader>fb :Buffers<CR>
"""nnoremap <Leader>fe :History<CR>
"""nnoremap <Leader>ft :Tags<CR>
"""nnoremap <Leader>fc :History:<CR>
"""nnoremap <Leader>fa :Ag<Space>
"""nnoremap <Leader>fs :Filetypes<CR>
"""nnoremap <Leader>fd :Ag <C-R><C-W><CR>

nnoremap <space>fg :GFiles<CR>
nnoremap <space>ff :Files<CR>
nnoremap <space>e :Buffers<CR>
nnoremap <space>h :History<CR>
nnoremap <space>s :Tags<CR>
nnoremap <space>g :Ag <Space>
nnoremap <space>gc :Ag <C-R><C-W><CR>

" ctags 
map <Leader>rr :!ctags -R --exclude=.git --exclude=node_modules --exclude=log *<Enter>

" bling/vim-airline
"" smarter tab line
let g:airline#extensions#tabline#enabled = 1
"" configure the formatting of filenames
let g:airline#extensions#tabline#fnamemod = ':t'

" pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1

" terminal
set splitbelow
nnoremap <F2> :ter ++rows=11<CR>
tnoremap <F3> <C-\><C-n>

" tagbar
nnoremap <Leader><F12> :TagbarOpenAutoClose<CR>

" previm
if has('macunix')
    let g:previm_open_cmd = 'open -a Google\ Chrome'
elseif has('unix')
    let g:previm_open_cmd = 'open -a Firefox'
endif

map <Leader>p :PrevimOpen<CR>
""" hide header to print html page
let g:previm_show_header = 0

" supertab
let g:SuperTabMappingForward = '<s-tab>'
let g:SuperTabMappingBackward = '<tab>'

" skwp/greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'
""" 1. Use :Gsearch to get a buffer window of your search results
""" 2. then you can make the replacements inside the buffer window using traditional tools (%s/foo/bar/)
""" 3. Invoke :Greplace to make your changes across all files. It will ask you interatively y/n/a - you can hit 'a' to do all.
""" 4. Save changes to all files with :wall (write all)
nnoremap <space>G :Gsearch<Space>

" othree/javascript-libraries-syntax.vim
let g:used_javascript_libs = 'jquery,underscore,backbone,react,vue'

" sirver/ultisnips
""" let g:UltiSnipsUsePythonVersion = 3

" Shifting blocks visually
nnoremap > >>
nnoremap < << 
vnoremap > >gv
vnoremap < <gv

" ale
"" keep the sign gutter open
let g:ale_sign_column_always = 1
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

"" show errors or warnings in my statusline
let g:airline#extensions#ale#enabled = 1

"" use quickfix list instead of the loclist
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

"" only enable these linters
"" let g:ale_linters = {
"" \    'javascript': ['eslint']
"" \}

"" Fix files with prettier, and then ESLint.
let b:ale_fixers = ['prettier', 'eslint']
let g:ale_fix_on_save = 1

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

"" run lint only on saving a file
let g:ale_lint_on_text_changed = 'never'
"" dont run lint on opening a file
"" let g:ale_lint_on_enter = 0

" scrooloose/nerdcommenter
"" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

"" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

"" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
