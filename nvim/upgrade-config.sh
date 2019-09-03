# /bin/sh

main() {
    mkdir ~/.config/nvim
    cp -r ./config/. ~/.config/nvim/

    nvim -c :PlugInstall
}

main
