# /bin/sh

main() {
    # ag
    sudo apt-get install -y silversearcher-ag

    # ctags
    sudo apt-get install -y ctags

    # ccls
    sudo snap install ccls --classic

    # vim-plug
    if [ ! -f "~/.vim/autoload/plug.vim" ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    cp ./.vimrc ~
    cp ./.ctags ~

    vim -c :PlugInstall
}

main
