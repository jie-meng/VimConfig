# /bin/sh

main() {
    # vim-plug
    if [ ! -f "~/.local/share/nvim/site/autoload/plug.vim" ]; then
        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    mkdir ~/.config/nvim
    cp -r ./config/. ~/.config/nvim/

    nvim -c :PlugInstall
}

main
