call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'

Plug 'kien/ctrlp.vim'

Plug 'vim-airline/vim-airline'

Plug 'flazz/vim-colorschemes'

Plug 'mileszs/ack.vim'

call plug#end()

" global 
set nu
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set hlsearch
let mapleader = ";"

" nerdtree
autocmd vimenter * NERDTree

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

map <C-n> :NERDTreeToggle<CR>

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" ctrlp
map <Leader>e :CtrlPBuffer<Enter>
let g:ctrlp_max_files = 0

" move between different window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" mileszs/ack.vim
" https://github.com/mileszs/ack.vim
let g:ack_use_cword_for_empty_search = 1
map <Leader>f :Ack!<Space>
map <Leader>fp :Ack! --python<Space>
map <Leader>fj :Ack! --java<Space> 
map <Leader>fx :Ack! --xml<Space> 
map <Leader>fs :Ack! --javascript<Space> 
