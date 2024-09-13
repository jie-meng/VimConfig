""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Basic configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
set wildignore+=*.pyc,*.o,*.obj,*.exe,*.class,*.DS_Store,*.meta
"" if hidden is not set, TextEdit might fail.
set hidden
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

"" remap C-p to C-i, because C-i sometimes override by other shortcuts
nnoremap <C-p> <C-i>

"" split window
nnoremap <Space>vs :vsplit<Enter>
nnoremap <Space>hs :split<Enter>

"" vimdiff
nnoremap <Space>ds :diffthis<Enter>

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

"" tagbar
nnoremap <Leader><F12> :TagbarOpenAutoClose<CR>

"" Shifting blocks visually
nnoremap > >
nnoremap < <<
vnoremap > >gv
vnoremap < <gv

"" terminal
set splitbelow
nnoremap <F2> :ter ++rows=11<CR>
tnoremap <F3> <C-\><C-n>

"" font
if has('macunix')
    set guifont=Monaco:h12
elseif has('unix')
    set guifont="Ubuntu Mono" 12
endif

"" ctags
map <Leader>rr :!ctags -R --exclude=.git --exclude=node_modules --exclude=log *<Enter>

"" disable auto-insert-line after RETURN on a autocomplete-list"
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

"" resize window
map <Leader>= :vertical resize +10<Enter>
map <Leader>- :vertical resize -10<Enter>
map <Leader>. :resize +10<Enter>
map <Leader>, :resize -10<Enter>

"" hightline current line and column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

"" close quickfix by type 'q' and return the cursor to the editor window
:autocmd FileType qf nnoremap <buffer>q :cclose<CR>:wincmd p<CR>

"" close quickfix after selection and return the cursor to the editor window
"" :autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>:wincmd p<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugin configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
""" Plug 'flazz/vim-colorschemes'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'rubberduck203/aosp-vim'
Plug 'skammer/vim-css-color'

" complete
Plug 'vim-scripts/AutoComplPop'
Plug 'ervandew/supertab'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'github/copilot.vim'

" language
Plug 'sheerun/vim-polyglot'
Plug 'moll/vim-node'
Plug 'kannokanno/previm'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'ap/vim-css-color'
Plug 'hail2u/vim-css3-syntax'
Plug 'vim-scripts/a.vim'
Plug 'aklt/plantuml-syntax'

" tools
Plug 'will133/vim-dirdiff'
Plug 'tyru/open-browser.vim'
Plug 'weirongxu/plantuml-previewer.vim'

" lint
Plug 'scrooloose/syntastic'

call plug#end()

""" colorscheme
colorscheme gruvbox
""" colorscheme deus
""" colorscheme ayu

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
"" startup width
let g:NERDTreeWinSize = 40

"" search dir
let g:NERDTreeChDirMode = 2
"" startup cursor in editing area
autocmd VimEnter * NERDTree | wincmd p
"" wildignore
let NERDTreeRespectWildIgnore=1

" vim-fugitive
nnoremap <Leader>gs :Git status<CR>
nnoremap <Leader>gc :Git commit<CR>
nnoremap <Leader>gb :Git blame<CR>
nnoremap <Leader>gm :Git move<CR>
nnoremap <Leader>gd :Git delete<CR>

" vim-gitgutter
nmap ]t <Plug>(GitGutterNextHunk)
nmap [t <Plug>(GitGutterPrevHunk)

" fzf
set rtp+=/usr/local/opt/fzf

nnoremap <space>fg :GFiles<CR>
nnoremap <space>ff :Files<CR>
nnoremap <space>e :Buffers<CR>
nnoremap <space>h :History<CR>
nnoremap <space>s :Tags<CR>
nnoremap <space>g :Ag <Space>
nnoremap <space>gc :Ag <C-R><C-W><CR>

" vim-airline/vim-airline
"" smarter tab line
let g:airline#extensions#tabline#enabled = 1
"" configure the formatting of filenames
let g:airline#extensions#tabline#fnamemod = ':t'

" pangloss/vim-javascript
let g:javascript_plugin_jsdoc = 1

" previm
if has('macunix')
    let g:previm_open_cmd = 'open -a Google\ Chrome'
elseif has('unix')
    let g:previm_open_cmd = 'open -a Firefox'
endif

" weirongxu/plantuml-previewer.vim
map <Leader>m :PrevimOpen<CR>
map <Leader>po :PlantumlOpen<CR>
nnoremap <Leader>ps :PlantumlSave <Space>

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
nnoremap <space>GS :Gsearch<Space>
nnoremap <space>GR :Greplace<Space>

" othree/javascript-libraries-syntax.vim
let g:used_javascript_libs = 'jquery,underscore,backbone,react,vue'

" scrooloose/nerdcommenter
"" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

"" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

"" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

"" prabirshrestha/asyncomplete
"" To enable preview window
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview

"" To auto close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" vim-lsp
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <space>rn <plug>(lsp-rename)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"" vim-lsp register cpp server
if executable('ccls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'ccls',
        \ 'cmd': {server_info->['ccls']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
        \	lsp#utils#find_nearest_parent_file_directory(
        \		lsp#utils#get_buffer_path(),
        \		['.ccls', 'compile_commands.json', '.git/']
        \	))},
        \ 'initialization_options': {},
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
        \ })
endif

"" disable highlighting error
" let g:lsp_diagnostics_highlights_enabled = 0
" let g:lsp_diagnostics_virtual_text_enabled = 0

" vim-lsp-settings
""" https://github.com/mattn/vim-lsp-settings
""" While editing a file with a supported filetype, :LspInstallServer server-name, if server-name not given, default server for the language will be used.
""" :LspUninstallServer server-name

" github/copilot.vim
map <space>ae :Copilot enable<CR>
map <space>ad :Copilot disable<CR>
map <space>as :Copilot status<CR>
map <space>ap :Copilot panel<CR>

