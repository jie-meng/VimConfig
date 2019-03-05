# /bin/sh

main() {
    # ag
    if brew ls --versions ag > /dev/null; then
        echo "You had install ag"
    else
        brew install ag
        # ubuntu: sudo apt-get install silversearcher-ag
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
        alias ctags="`brew --prefix`/bin/ctags"
    fi

    # python autocomplete
    pip3 install jedi

    # vim-plug
    if [ ! -f "~/.vim/autoload/plug.vim" ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
}

main
