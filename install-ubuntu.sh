# /bin/sh

main() {
    # ag
    sudo apt-get install -y silversearcher-ag

    sudo apt-get install -y ctags

    pip3 install jedi

    # vim-plug
    if [ ! -f "~/.vim/autoload/plug.vim" ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi


    cp ./.vimrc ~

    vim -c :PlugInstall
}

main
