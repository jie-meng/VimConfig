call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'

Plug 'kien/ctrlp.vim'

Plug 'vim-airline/vim-airline'

Plug 'flazz/vim-colorschemes'

Plug 'mileszs/ack.vim'

Plug 'terryma/vim-multiple-cursors'

Plug 'easymotion/vim-easymotion'

Plug 'vim-scripts/a.vim'

Plug 'pangloss/vim-javascript'

call plug#end()

" global 
set nu
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set hlsearch

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
map <Leader>j :NERDTreeFind<Enter>
inoremap <Leader>j <Esc>:NERDTreeFind<Enter>
"" folder icon
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"" search dir
let g:NERDTreeChDirMode = 2

" ctags
map <Leader>rr :!ctags -R --exclude=.git --exclude=log *<Enter>

" ctrlp
map <Leader>e :CtrlPBuffer<Enter>
let g:ctrlp_max_files = 0
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_working_path_mode = 'rw'

" move between different window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" mileszs/ack.vim
" https://github.com/mileszs/ack.vim
let g:ack_use_cword_for_empty_search = 1
map <Leader>f :Ack!<Space>
map <Leader>fc :Ack! --cpp <cword>
map <Leader>fp :Ack! --python <cword>
map <Leader>fj :Ack! --java <cword> 
map <Leader>fx :Ack! --xml <cword> 
map <Leader>fs :Ack! --javascript <cword> 

map <Leader>ffc :Ack! --cpp<Space>
map <Leader>ffp :Ack! --python<Space>
map <Leader>ffj :Ack! --java<Space> 
map <Leader>ffx :Ack! --xml<Space> 
map <Leader>ffs :Ack! --javascript<Space> 

" pangloss/vim-javascript'
let g:javascript_plugin_jsdoc = 1
