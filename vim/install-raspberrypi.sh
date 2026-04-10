#!/bin/sh

set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

main() {
    sudo apt-get update

    # vim
    if command_exists vim; then
        echo "vim is already installed: $(vim --version | head -1)"
        echo "Upgrading vim to latest available version..."
        sudo apt-get install -y --only-upgrade vim
    else
        echo "Installing vim..."
        sudo apt-get install -y vim
    fi

    # curl (needed for vim-plug download)
    if ! command_exists curl; then
        sudo apt-get install -y curl
    fi

    # git (needed for vim-plug plugins)
    if ! command_exists git; then
        sudo apt-get install -y git
    fi

    # ag
    sudo apt-get install -y silversearcher-ag

    # fzf
    sudo apt-get install -y fzf

    # ctags
    sudo apt-get install -y universal-ctags || sudo apt-get install -y exuberant-ctags

    # ccls (no snap on Raspberry Pi OS, use apt)
    sudo apt-get install -y ccls || echo "Warning: ccls not available in repos, skipping."

    # vim-plug
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        echo "Installing vim-plug..."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "vim-plug already installed."
    fi

    cp ./.vimrc ~
    cp ./.ctags ~

    vim -c ':PlugInstall' -c ':qa'
}

main
