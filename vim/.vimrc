""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Basic configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"" global
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
" set ignorecase

"" performance enhancement
"" disable swap, backup, writebackup
set noswapfile
set nobackup
set nowritebackup
"" decrease screen refresh frequency
set lazyredraw
"" decrease statusbar refresh frequency
set updatetime=300

"" For Neovim 0.1.3 and 0.1.4 - https://github.com/neovim/neovim/pull/2198
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

"" For Neovim > 0.1.5 and Vim > patch 7.4.1799 - https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162
"" Based on Vim patch 7.4.1770 (`guicolors` option) - https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd
"" https://github.com/neovim/neovim/wiki/Following-HEAD#20160511
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

let $MYVIMRC = expand('~/.vimrc')
"" quick edit .vimrc
map <Leader><F2> :e $MYVIMRC<CR>
"" quick reload .vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

"" change buffer
map <Leader>[ :bp<Enter>
map <Leader>] :bn<Enter>

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
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set smartindent

augroup FileTypeIndent
    autocmd!
    autocmd FileType javascript,typescript,yaml,yml,json setlocal tabstop=2 shiftwidth=2
augroup END

"" Shifting blocks visually
nnoremap > >>
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
inoremap <expr> <C-l> pumvisible() ? "\<C-e>" : "\<C-l>"

"" resize window
map <space>. :vertical resize +10<Enter>
map <space>, :vertical resize -10<Enter>
map <space>= :resize +10<Enter>
map <space>- :resize -10<Enter>

"" hightline current line and column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

augroup QuickFixPosition
    autocmd!
    autocmd FileType qf wincmd J
augroup END

"" close quickfix by type 'q' and return the cursor to the editor window
:autocmd FileType qf nnoremap <buffer>q :cclose<CR>:wincmd p<CR>

"" close quickfix after selection and return the cursor to the editor window
" :autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>:wincmd p<CR>

"" global functions
function! CopyToClipboard(text)
    if empty(a:text)
        echo "No text to copy."
        return
    endif

    let l:escaped_text = shellescape(a:text)

    if has('clipboard')
        let @+ = a:text
        let l:copy_success = 1
    elseif has('mac')
        call system('echo ' . l:escaped_text . ' | pbcopy')
        let l:copy_success = v:shell_error == 0
    elseif has('unix')
        " Try different Linux clipboard tools
        if executable('xclip')
            call system('echo ' . l:escaped_text . ' | xclip -selection clipboard')
            let l:copy_success = v:shell_error == 0
        elseif executable('xsel')
            call system('echo ' . l:escaped_text . ' | xsel --clipboard --input')
            let l:copy_success = v:shell_error == 0
        elseif executable('wl-copy')
            call system('echo ' . l:escaped_text . ' | wl-copy')
            let l:copy_success = v:shell_error == 0
        else
            let l:copy_success = 0
        endif
    elseif has('win32') || has('win64')
        call system('echo ' . l:escaped_text . ' | clip')
        let l:copy_success = v:shell_error == 0
    else
        let l:copy_success = 0
    endif

    if l:copy_success
        echo "Copied to clipboard: " . a:text
    else
        echo "Unable to copy to clipboard. Unsupported system or missing clipboard tool."
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugin configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

"" window
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'xolox/vim-misc'

"" search
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

"" edit
Plug 'skwp/greplace.vim'
Plug 'arthurxavierx/vim-caser'
Plug 'scrooloose/nerdcommenter'

"" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'

"" color
Plug 'rafi/awesome-vim-colorschemes'
Plug 'rubberduck203/aosp-vim'

"" complete
Plug 'ervandew/supertab'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'github/copilot.vim'
" Plug 'Exafunction/windsurf.vim', { 'branch': 'main' }

"" language
Plug 'sheerun/vim-polyglot'
Plug 'kannokanno/previm'
Plug 'ap/vim-css-color'
Plug 'vim-scripts/a.vim'

"" tools
Plug 'will133/vim-dirdiff'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'tpope/vim-dispatch'
Plug 'vim-test/vim-test'
Plug 'rhysd/vim-clang-format'

"" framework
Plug 'normen/vim-pio'

call plug#end()

"" <colorscheme>
colorscheme gruvbox
" colorscheme molokai
" colorscheme deus
" colorscheme ayu

"" colorscheme override
" hi Search guibg=peru guifg=wheat
" hi CursorLine term=bold cterm=bold guibg=Grey20
" hi CursorColumn term=bold cterm=bold guibg=Grey20

"" popup menu override
"" https://alvinalexander.com/linux/vi-vim-editor-color-scheme-syntax/
"" https://vi.stackexchange.com/questions/12664/is-there-any-way-to-change-the-popup-menu-color
" :highlight Pmenu ctermbg=DarkMagenta guibg=DarkMagenta
" :highlight PmenuSel ctermbg=DarkMagenta guibg=DarkMagenta
" :highlight PmenuSbar ctermbg=DarkMagenta guibg=DarkMagenta
" :highlight PmenuThumb ctermbg=DarkMagenta guibg=DarkMagenta

"" <scrooloose/nerdtree>
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
" autocmd BufWinEnter * NERDTreeFind
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

"" <tagbar>
nnoremap <Leader><F12> :TagbarToggle<CR>

"" <vim-fugitive>
function! s:git_status_to_quickfix()
  "" Get the output of git status --porcelain
  let l:git_status = system('git status --porcelain')

  "" Split the output into lines
  let l:lines = split(l:git_status, "\n")

  "" Initialize an empty list for Quickfix entries
  let l:quickfix_list = []

  "" Process each line
  for l:line in l:lines
    if l:line =~ '^\s*$'
      continue
    endif

    "" Extract the status part
    let l:status = matchstr(l:line, '^\s*\zs\S\+')

    "" Extract the file path (ignoring the status part)
    let l:filepath = matchstr(l:line, '\v\S+\s+\zs.*')

    "" Create a Quickfix entry
    call add(l:quickfix_list, {
          \ 'filename': l:filepath,
          \ 'lnum': 1,
          \ 'col': 1,
          \ 'text': l:status,
          \ })
  endfor

  "" Populate the Quickfix list with the entries
  call setqflist(l:quickfix_list, 'r')

  "" Open the Quickfix window
  copen
endfunction

"" Command to call the function
command! GitQuickfix call s:git_status_to_quickfix()

function! s:git_diff_head_and_split()
    " Use vertical split to open Gdiff HEAD
    execute 'leftabove vertical Gdiff HEAD'
endfunction

" nnoremap <Leader>gs :Git status<CR>
" nnoremap <Leader>gd :Gdiff HEAD<CR>
nnoremap <space>gc :Git commit<CR>
nnoremap <space>gb :Git blame<CR>
nnoremap <space>gm :Git move<CR>
nnoremap <space>gr :Git delete<CR>
nnoremap <space>gs :GitQuickfix<CR>
nnoremap <space>gd :call <SID>git_diff_head_and_split()<CR>

"" <vim-gitgutter>
nmap g] <Plug>(GitGutterNextHunk)
nmap g[ <Plug>(GitGutterPrevHunk)

"" <fzf>
set rtp+=/usr/local/opt/fzf

nnoremap <space>fg :GFiles<CR>
nnoremap <space>ff :Files<CR>
nnoremap <space>fe :Buffers<CR>
nnoremap <space>fh :History<CR>
nnoremap <space>ft :Tags<CR>
nnoremap <space>fs :Ag <Space>
nnoremap <space>fw :Ag <C-R><C-W><CR>

"" <vim-test>
function! CustomStrategy(cmd)
    let g:last_test_command = a:cmd
    execute '!'.a:cmd
endfunction

let g:test#preserve_screen = 0
let g:test#javascript#runner = 'jest'
let g:test#custom_strategies = {'custom': function('CustomStrategy')}
let g:test#strategy = 'custom'

nmap <space>tn :TestNearest<CR>
nmap <space>tf :TestFile<CR>
nmap <space>ts :TestSuite<CR>
nmap <space>tl :TestLast<CR>
nmap <space>tv :TestVisit<CR>
nmap <space>tc :call CopyToClipboard(get(g:, 'last_test_command', ''))<CR>

"" <vim-airline/vim-airline>
"" smarter tab line
let g:airline_extensions = []
" let g:airline#extensions#tabline#enabled = 1
"" configure the formatting of filenames
" let g:airline#extensions#tabline#fnamemod = ':t'

"" <pangloss/vim-javascript>
let g:javascript_plugin_jsdoc = 1

"" <previm>
if has('macunix')
    let g:previm_open_cmd = 'open -a Google\ Chrome'
elseif has('unix')
    let g:previm_open_cmd = 'open -a Firefox'
endif

"" <weirongxu/plantuml-previewer.vim>
map <Leader>m :PrevimOpen<CR>
map <Leader>po :PlantumlOpen<CR>
nnoremap <Leader>ps :PlantumlSave <Space>

"" hide header to print html page
let g:previm_show_header = 0

"" <supertab>
let g:SuperTabMappingForward = '<s-tab>'
let g:SuperTabMappingBackward = '<tab>'

"" <skwp/greplace>
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'
"" 1. Use :Gsearch to get a buffer window of your search results
"" 2. then you can make the replacements inside the buffer window using traditional tools (%s/foo/bar/)
"" 3. Invoke :Greplace to make your changes across all files. It will ask you interatively y/n/a - you can hit 'a' to do all.
"" 4. Save changes to all files with :wall (write all)
nnoremap <space>GS :Gsearch<Space>
nnoremap <space>GR :Greplace<Space>

"" <othree/javascript-libraries-syntax.vim>
let g:used_javascript_libs = 'jquery,underscore,backbone,react,vue'

"" <scrooloose/nerdcommenter>
"" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

"" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

"" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

"" <prabirshrestha/asyncomplete>
"" To enable preview window
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 1
set completeopt=menuone,noinsert,noselect,preview

"" To auto close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

"" <vim-lsp>
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

    "" refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    "" call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"" vim-lsp register cpp server
if executable('clangd')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '--background-index', '--compile-commands-dir=.']},
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(
        \   lsp#utils#find_nearest_parent_file_directory(
        \     lsp#utils#get_buffer_path(),
        \     ['compile_commands.json', '.clangd', '.git/', 'CMakeLists.txt']
        \   )
        \ )},
        \ 'allowlist': [
        \   'c', 'cpp', 'objc', 'objcpp',
        \   'cc', 'cxx', 'h', 'hpp', 'hxx'
        \ ],
        \ })
endif

"" disable highlighting error
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_virtual_text_prefix = "<✗> "
let g:lsp_diagnostics_virtual_text_insert_mode_enabled = 0
let g:lsp_diagnostics_delay = 2000

"" Customize the highlight groups for diagnostics signs
highlight LspDiagnosticsSignError guifg=#FFFFFF guibg=#FF0000 ctermfg=15 ctermbg=1
highlight LspDiagnosticsSignWarning guifg=#FFFFFF guibg=#FFA500 ctermfg=15 ctermbg=214
highlight LspDiagnosticsSignInformation guifg=#FFFFFF guibg=#0000FF ctermfg=15 ctermbg=4
highlight LspDiagnosticsSignHint guifg=#FFFFFF guibg=#00FF00 ctermfg=15 ctermbg=2


"" <vim-lsp-settings>
"" https://github.com/mattn/vim-lsp-settings
"" While editing a file with a supported filetype, :LspInstallServer server-name, if server-name not given, default server for the language will be used.
"" :LspUninstallServer server-name

"" <github/copilot.vim>
"" let b:copilot_enabled = v:true

map <space>ae :Copilot enable<CR>
map <space>ad :Copilot disable<CR>
map <space>as :Copilot status<CR>
map <space>ap :Copilot panel<CR>
map <space>au :Copilot setup<CR>
map <space>ao :Copilot signout<CR>

"" <Exafunction/windsurf.vim>
" let g:codeium_enabled = v:false

"" format code
command! PrettierFormat call s:FormatWithPrettier()
command! Autopep8Format call s:FormatWithAutopep8()

" Function to format with Prettier
function! s:FormatWithPrettier()
  let l:current_file = expand('%:p')
  call system('npx prettier --write ' . l:current_file)
  edit!
endfunction

" Function to format with Autopep8
function! s:FormatWithAutopep8()
  let l:current_file = expand('%:p')
  call system('autopep8 --in-place --aggressive --aggressive ' . l:current_file)
  edit!
endfunction

" Create FormatCode function
function! FormatCode()
  " Get the current file type
  let l:filetype = &filetype

  " Execute the appropriate formatting command based on the file type
  if l:filetype == 'javascript' || l:filetype == 'typescript' || l:filetype == 'typescriptreact' || l:filetype == 'css' || l:filetype == 'scss' || l:filetype == 'html'
    call s:FormatWithPrettier()
  elseif l:filetype == 'python'
    call s:FormatWithAutopep8()
  else
    echo "Unsupported file type: " . l:filetype
  endif
endfunction

"" Map <Leader>pf to call the FormatCode function
nnoremap <Leader>fc :call FormatCode()<CR>

"" vim-clang-format
let g:clang_format#detect_style_file = 1
let g:clang_format#auto_format = 1
nnoremap <Leader>cf :ClangFormat<CR>
