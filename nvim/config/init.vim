" https://github.com/junegunn/vim-plug

call plug#begin('~/.config/nvim/plugged')

" coc, full language server protocol support as VSCode
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" window
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" colorschemes
Plug 'flazz/vim-colorschemes'

" edit
Plug 'skwp/greplace.vim'
Plug 'arthurxavierx/vim-caser'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'

" language
Plug 'sheerun/vim-polyglot'
Plug 'moll/vim-node'
Plug 'kannokanno/previm'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'ap/vim-css-color'
Plug 'hail2u/vim-css3-syntax'
Plug 'vim-scripts/a.vim'

call plug#end()

" load config from modules
source ~/.config/nvim/neovim.config.vim
source ~/.config/nvim/nerdtree.config.vim
source ~/.config/nvim/vim_airline.config.vim
source ~/.config/nvim/coc.config.vim
source ~/.config/nvim/colorschemes.config.vim
source ~/.config/nvim/git_fugitive.config.vim
source ~/.config/nvim/greplace.config.vim
source ~/.config/nvim/previm.config.vim
source ~/.config/nvim/javascript_libraries_syntax.config.vim
