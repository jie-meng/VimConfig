" https://github.com/skwp/greplace.vim

set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'
""" 1. Use :Gsearch to get a buffer window of your search results
""" 2. then you can make the replacements inside the buffer window using traditional tools (%s/foo/bar/)
""" 3. Invoke :Greplace to make your changes across all files. It will ask you interatively y/n/a - you can hit 'a' to do all.
""" 4. Save changes to all files with :wall (write all)
nnoremap <Leader>G :Gsearch<Space>