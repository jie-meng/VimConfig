#!/bin/sh
#
# Install script for RHEL-based distros:
#   - Alibaba Cloud Linux 2 / 3
#   - CentOS 7 / 8 / 9
#   - RHEL 7 / 8 / 9
#   - Rocky Linux / AlmaLinux
#
# Note: EPEL is required for ag, fzf, and universal-ctags.
# This script enables EPEL automatically if it is not already enabled.

set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect package manager: prefer dnf, fall back to yum
if command_exists dnf; then
    PKG="sudo dnf"
elif command_exists yum; then
    PKG="sudo yum"
else
    echo "Error: neither dnf nor yum found. Is this a RHEL-based system?" >&2
    exit 1
fi

main() {
    # Enable EPEL if not already present (provides ag, fzf, ctags)
    if ! $PKG repolist enabled 2>/dev/null | grep -q 'epel'; then
        echo "Enabling EPEL repository..."
        if command_exists dnf; then
            sudo dnf install -y epel-release
        else
            sudo yum install -y epel-release
        fi
    fi

    $PKG makecache

    # vim-enhanced (the standard vim package on RHEL; plain 'vim' is vim-minimal)
    if command_exists vim; then
        echo "vim is already installed: $(vim --version | head -1)"
        $PKG upgrade -y vim-enhanced
    else
        echo "Installing vim-enhanced..."
        $PKG install -y vim-enhanced
    fi

    # curl (needed for vim-plug download)
    if ! command_exists curl; then
        $PKG install -y curl
    fi

    # git (needed for vim-plug plugins)
    if ! command_exists git; then
        $PKG install -y git
    fi

    # ag (the_silver_searcher) — provided by EPEL
    $PKG install -y the_silver_searcher

    # fzf — provided by EPEL
    $PKG install -y fzf

    # ctags — universal-ctags is in EPEL on newer distros; fall back to ctags
    $PKG install -y universal-ctags 2>/dev/null || \
        $PKG install -y ctags 2>/dev/null || \
        echo "Warning: no ctags package found in repos, skipping."

    # ccls — not available in RHEL/EPEL repos; skip with notice
    echo "Note: ccls is not available in standard RHEL repos. Install from source if needed:"
    echo "  https://github.com/MaskRay/ccls"

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

main "$@"
