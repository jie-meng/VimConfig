# /bin/sh

main() {
    brew update

    # nvim
    brew install --HEAD neovim
    
    # ripgrep
    brew install ripgrep

    # ccls
    brew install ccls

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
