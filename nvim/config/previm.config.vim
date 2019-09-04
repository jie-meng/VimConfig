" https://github.com/previm/previm

" previm
if has('macunix')
    let g:previm_open_cmd = 'open -a Google\ Chrome'
elseif has('unix')
    let g:previm_open_cmd = 'open -a Firefox'
endif

map <Leader>p :PrevimOpen<CR>
""" hide header to print html page
let g:previm_show_header = 0