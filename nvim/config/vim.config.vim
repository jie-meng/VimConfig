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
" https://vim.fandom.com/wiki/Shifting_blocks_visually
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" move between different window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" quit
nmap <Leader>w :wq<Enter>
nmap <Leader>q :q!<Enter>
imap <Leader>w <Esc>:wq<Enter>
imap <Leader>q <Esc>:q!<Enter>
nmap <C-s> :w<Enter>

" resize window
map <Leader>- :resize -10<Enter>
map <Leader>+ :resize +10<Enter>
map <Leader>< :vertical resize -10<Enter>
map <Leader>> :vertical resize +10<Enter>
"" hightline current line and column
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

" font
if has('macunix')
  set guifont=Monaco:h14
elseif has('unix')
  set guifont=Monospace\ 14
endif

" tab spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

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
map <Leader><F11> :below terminal<Enter>

"" split window
map <Leader>sv :vsplit<Enter>
map <Leader>sh :split<Enter>