" https://github.com/junegunn/vim-plug

call plug#begin('~/.config/nvim/plugged')

" vim-devicons, adds file type icons to Vim
""" Plug 'ryanoasis/vim-devicons'

" nerdtree, project tree on the left
Plug 'scrooloose/nerdtree'
" nerdtree-git-plugin, support git status on nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
" vim-nerdtree-syntax-highlight, display different icon by file type
""" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" vim-airline, a statusline
Plug 'vim-airline/vim-airline'
" vim-airline-themes, more Theme for vim-airline
Plug 'vim-airline/vim-airline-themes'

" coc, full language server protocol support as VSCode
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" colorschemes
Plug 'flazz/vim-colorschemes'

" edit
Plug 'skwp/greplace.vim'
Plug 'arthurxavierx/vim-caser'
Plug 'scrooloose/nerdcommenter'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'

" language
Plug 'kannokanno/previm'

call plug#end()

" load config from modules
source ~/.config/nvim/neovim.config.vim
source ~/.config/nvim/nerdtree.config.vim
source ~/.config/nvim/vim_airline.config.vim
source ~/.config/nvim/vim_airline_themes.config.vim
source ~/.config/nvim/coc.config.vim
source ~/.config/nvim/colorschemes.config.vim
source ~/.config/nvim/git_fugitive.config.vim
source ~/.config/nvim/greplace.config.vim
source ~/.config/nvim/previm.config.vim