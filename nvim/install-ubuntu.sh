#!/bin/bash

# ============================================================================
# Neovim Installation Script for Ubuntu/Debian
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Neovim Installation Script for Ubuntu/Debian ===${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root${NC}" 
   exit 1
fi

# Update package list
echo -e "${GREEN}Updating package list...${NC}"
sudo apt-get update

# Install Neovim
echo -e "${GREEN}Installing Neovim...${NC}"
# Install the latest stable Neovim from official PPA
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt-get update
sudo apt-get install -y neovim

# Install essential dependencies
echo -e "${GREEN}Installing essential dependencies...${NC}"
sudo apt-get install -y \
    curl \
    wget \
    unzip

# Install ripgrep (for telescope live_grep)
echo -e "${GREEN}Installing ripgrep (for text search)...${NC}"
if ! command -v rg &> /dev/null; then
    # Install from GitHub releases for latest version
    RG_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb"
    sudo dpkg -i "ripgrep_${RG_VERSION}_amd64.deb"
    rm "ripgrep_${RG_VERSION}_amd64.deb"
else
    echo -e "${YELLOW}ripgrep is already installed.${NC}"
fi

# Install fd (for telescope find_files)
echo -e "${GREEN}Installing fd (for file search)...${NC}"
if ! command -v fd &> /dev/null; then
    sudo apt-get install -y fd-find
    # Create symlink for fd command
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd
else
    echo -e "${YELLOW}fd is already installed.${NC}"
fi


# Install fzf
echo -e "${GREEN}Installing fzf (for fuzzy search)...${NC}"
if ! command -v fzf &> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo -e "${YELLOW}fzf is already installed.${NC}"
fi

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}Adding ~/.local/bin to PATH...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create config directory
echo -e "${GREEN}Creating Neovim config directory...${NC}"
mkdir -p ~/.config/nvim

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sync configuration to system
echo -e "${GREEN}Syncing configuration to system...${NC}"
if [ -f "$SCRIPT_DIR/sync-to-system.sh" ]; then
    chmod +x "$SCRIPT_DIR/sync-to-system.sh"
    "$SCRIPT_DIR/sync-to-system.sh"
else
    echo -e "${YELLOW}sync-to-system.sh not found. You may need to manually copy the config files.${NC}"
fi

echo -e "${GREEN}✓ Installation completed successfully!${NC}"
echo -e "${BLUE}=== What's included ===${NC}"
echo -e "${GREEN}✓ Neovim${NC}"
echo -e "${GREEN}✓ ripgrep (text search)${NC}"
echo -e "${GREEN}✓ fd (file search)${NC}"
echo -e "${GREEN}✓ fzf (fuzzy search)${NC}"
echo ""
echo -e "${BLUE}=== What you may need to install later ===${NC}"
echo -e "${YELLOW}- Additional language servers via :Mason (Rust, Go, etc.)${NC}"
echo -e "${YELLOW}- Code formatters (prettier, autopep8, stylua, etc.)${NC}"
echo -e "${YELLOW}- Git (usually pre-installed)${NC}"
echo -e "${YELLOW}- Node.js/Python3 (if you need specific language support)${NC}"
echo ""
echo -e "${BLUE}=== Next Steps ===${NC}"
echo -e "${YELLOW}1. Reload your shell: source ~/.bashrc${NC}"
echo -e "${YELLOW}2. Run 'nvim' to start Neovim${NC}"
echo -e "${YELLOW}3. Lazy.nvim will automatically install all plugins on first launch${NC}"
echo -e "${YELLOW}4. Configuration complete! Please restart your terminal.${NC}"
echo -e "${YELLOW}5. You may need to install additional LSP servers using :Mason in nvim${NC}"
echo ""
echo -e "${GREEN}Happy coding with Neovim! 🎉${NC}"
