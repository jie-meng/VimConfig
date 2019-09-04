" support mouse
:set mouse=a

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

" Alt + * move line
" http://vim.wikia.com/wiki/Moving_lines_up_or_down
if has('macunix')
  nnoremap ∆ :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv
elseif has('unix')
  nnoremap <A-j> :m .+1<CR>==
  nnoremap <A-k> :m .-2<CR>==
  inoremap <A-j> <Esc>:m .+1<CR>==gi
  inoremap <A-k> <Esc>:m .-2<CR>==gi
  vnoremap <A-j> :m '>+1<CR>gv=gv
  vnoremap <A-k> :m '<-2<CR>gv=gv
endif

" Shifting blocks visually
nnoremap > >>
nnoremap < << 
vnoremap > >gv
vnoremap < <gv

"" move
nnoremap mb ^
nnoremap me $
vnoremap mb ^
vnoremap me $

" quit
nmap <Leader>w :wq<Enter>
nmap <Leader>q :q!<Enter>
imap <Leader>w <Esc>:wq<Enter>
imap <Leader>q <Esc>:q!<Enter>
nmap <C-s> :w<Enter>

" resize window
map <Leader>= :vertical resize +10<Enter>
map <Leader>- :vertical resize -10<Enter>
map <Leader>. :resize +10<Enter>
map <Leader>, :resize -10<Enter>

"" hightline current line and column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

" font
if has('macunix')
  set guifont=Hack\ Nerd\ Font:h14
elseif has('unix')
  set guifont=Hack\ Nerd\ Font\ 14
endif

" tab spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set path+=directory/**

" line number
set nu

" Disable end of line
:set nofixendofline

" Auto reload file when file changed
:set autoread
au FocusGained * :checktime

" hide scroll
set guioptions-=L
set guioptions-=r

" support copy & paste by Ctrl C/V
:inoremap <C-v> <ESC>"+pa
:vnoremap <C-c> "+y
:vnoremap <C-d> "+d

"" switch window
map <Leader>[ :bp<Enter>
map <Leader>] :bn<Enter>

"" terminal

"" split window
map <Leader>sv :vsplit<Enter>
map <Leader>sh :split<Enter>

" Toggle terminal
nnoremap <F3> :call ToggleTerm("term-slider", 1)<CR>
 
function! ToggleTerm(termname, slider)
    let pane = bufwinnr(a:termname)
    let buf = bufexists(a:termname)
    if pane > 0
        " pane is visible
        if a:slider > 0
            :exe pane . "wincmd c"
        else
            :exe "e #"
        endif
    elseif buf > 0
        " buffer is not in pane
        if a:slider
            :exe "botright split +resize10"
        endif
        :exe "buffer " . a:termname
    else
        " buffer is not loaded, create
        if a:slider
            :exe "botright split +resize10"
        endif
        :terminal
        :exe "f " a:termname
    endif
endfunction