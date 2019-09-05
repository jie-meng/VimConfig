# /bin/sh

main() {
    mkdir ~/.config/nvim
    rm ~/.config/nvim/*.vim
    rm ~/.config/nvim/*.json
    cp -r ./config/. ~/.config/nvim/

    nvim -c :PlugInstall
}

main
