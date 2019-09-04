# /bin/sh

main() {
    mkdir ~/.config/nvim
    rm ~/.config/*.vim
    cp -r ./config/. ~/.config/nvim/

    nvim -c :PlugInstall
}

main
