call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'

Plug 'vim-airline/vim-airline'

Plug 'flazz/vim-colorschemes'

Plug 'terryma/vim-multiple-cursors'

Plug 'easymotion/vim-easymotion'

Plug 'vim-scripts/a.vim'

Plug 'pangloss/vim-javascript'

Plug 'airblade/vim-gitgutter'

Plug 'majutsushi/tagbar'

Plug 'xolox/vim-misc'

Plug 'crusoexia/vim-monokai'

Plug 'junegunn/fzf'

Plug 'junegunn/fzf.vim'

Plug 'davidhalter/jedi-vim'

Plug 'kannokanno/previm'

call plug#end()

" global 
filetype on
syntax on 
colorscheme monokai

set nu
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set hlsearch
set nocompatible
set backspace=indent,eol,start
set smartindent
set showmatch

"" quick edit vimrc
map <Leader><F2> :e ~/.vimrc<CR>

"" chagne buffer
map <Leader>[ :bp<Enter>
map <Leader>] :bn<Enter>

"" Disable swap
set noswapfile

"" enable clipboard 
:inoremap <C-v> <ESC>"+pa
:vnoremap <C-c> "+y
:vnoremap<C-d> "+d

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
    set guifont=Monaco:h14
elseif has('unix')
    set guifont="Ubuntu Mono" 14
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
map <Leader>n :NERDTreeToggle<Enter>
"" locate current file in the tree
nnoremap <Leader>j :NERDTreeFind<Enter>
inoremap <Leader>j <Esc>:NERDTreeFind<Enter>
""" autocmd BufWinEnter * NERDTreeFind
"" folder icon
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"" search dir
let g:NERDTreeChDirMode = 2

" vim-fugitive'
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gc :Gcommit<CR>

" fzf
set rtp+=/usr/local/opt/fzf

nmap <Leader>F :Files<CR>
nmap <Leader>f :GFiles<CR>
nmap <Leader>b :Buffers<CR>
nmap <Leader>t :BTags<CR>
nmap <Leader>h :History<CR>
nmap <Leader>T :Tags<CR>
nmap <Leader>: :History:<CR>
nmap <Leader>/ :History/<CR>
nmap <Leader>l :BLines<CR>
nmap <Leader>L :Lines<CR>
nmap <Leader>' :Marks<CR>
nmap <Leader>a :Ag<Space>
nmap <Leader>H :Helptags!<CR>
nmap <Leader>C :Commands<CR>
nmap <Leader>M :Maps<CR>
nmap <Leader>s :Filetypes<CR>

" ctags 
map <Leader>rr :!ctags -R --exclude=.git --exclude=log *<Enter>

" bling/vim-airline
"" smarter tab line
let g:airline#extensions#tabline#enabled = 1
"" configure the formatting of filenames
let g:airline#extensions#tabline#fnamemod = ':t'

" move between different window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1

" terminal
set splitbelow
map <Leader>` :ter ++rows=20<Enter>

" tagbar
nnoremap <Leader><F12> :TagbarOpenAutoClose<CR>

" previm
if has('macunix')
    let g:previm_open_cmd = 'open -a Google\ Chrome'
elseif has('unix')
    let g:previm_open_cmd = 'open -a Firefox'
endif

map <Leader>P :PrevimOpen<CR>

