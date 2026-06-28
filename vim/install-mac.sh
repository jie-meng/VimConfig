#!/bin/sh

main() {
    # ag (the_silver_searcher)
    if brew ls --versions the_silver_searcher > /dev/null; then
        echo "You had install ag"
    else
        brew install the_silver_searcher
    fi

    # fzf
    if brew ls --versions fzf > /dev/null; then
        echo "You had install fzf"
    else
        brew install fzf
        $(brew --prefix)/opt/fzf/install
    fi

    # ctags
    if brew ls --versions ctags > /dev/null; then
        echo "You had install ctags"
    else
        brew install ctags
        # Note: add the following to your ~/.zshrc or ~/.bashrc to use Homebrew ctags:
        # alias ctags="$(brew --prefix)/bin/ctags"
    fi

    # ccls
    brew install ccls

    # vim-plug
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    cp ./.vimrc ~
    cp ./.ctags ~

    vim -c :PlugInstall
}

main
