call plug#begin('~/.config/nvim/plugged')

" nerdtree, project tree on the left
Plug 'scrooloose/nerdtree'
" nerdtree-git-plugin, support git status on nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
" vim-nerdtree-syntax-highlight, display different icon by file type
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" vim-airline, a statusline
Plug 'vim-airline/vim-airline'
" vim-airline-themes, more Theme for vim-airline
Plug 'vim-airline/vim-airline-themes'

" coc, full language server protocol support as VSCode
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" typescript-vim, support typescript
Plug 'leafgarland/typescript-vim'

" vim-tsx, support tsx
Plug 'peitalin/vim-jsx-typescript'

" minimalist, a good color scheme
Plug 'dikiaap/minimalist'

call plug#end()

" load config from modules
source ~/.config/nvim/vim.config.vim
source ~/.config/nvim/nerdtree.config.vim
source ~/.config/nvim/vim_airline.config.vim
source ~/.config/nvim/vim_airline_themes.config.vim
source ~/.config/nvim/coc.config.vim
source ~/.config/nvim/vim_jsx_typescript.config.vim
