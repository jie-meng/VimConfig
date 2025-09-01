#!/bin/bash

# ============================================================================
# Neovim Installation Script for macOS
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Neovim Installation Script for macOS ===${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed. Please install Homebrew first:${NC}"
    echo -e "${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    exit 1
fi

# Update Homebrew
# echo -e "${GREEN}Updating Homebrew...${NC}"
# brew update

# Install Neovim
echo -e "${GREEN}Installing Neovim...${NC}"
if brew list neovim &> /dev/null; then
    echo -e "${YELLOW}Neovim is already installed. Upgrading...${NC}"
    brew upgrade neovim
else
    brew install neovim
fi


# Install essential dependencies
echo -e "${GREEN}Installing essential dependencies...${NC}"

# ripgrep (for telescope live_grep)
if ! command -v rg &> /dev/null; then
    echo -e "${YELLOW}Installing ripgrep (for text search)...${NC}"
    brew install ripgrep
fi

# fd (for telescope find_files)
if ! command -v fd &> /dev/null; then
    echo -e "${YELLOW}Installing fd (for file search)...${NC}"
    brew install fd
fi

# fzf (for telescope fzf extension)
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}Installing fzf (for fuzzy search)...${NC}"
    brew install fzf
fi

# Install im-select for input method switching
echo -e "${GREEN}Installing im-select (for input method switching)...${NC}"
if ! command -v im-select &> /dev/null; then
    brew tap daipeihust/tap
    brew install im-select
else
    echo -e "${YELLOW}im-select is already installed.${NC}"
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
echo -e "${YELLOW}- Git (usually pre-installed on macOS)${NC}"
echo -e "${YELLOW}- Node.js/Python3 (if you need specific language support)${NC}"
echo ""
echo -e "${BLUE}=== Next Steps ===${NC}"
echo -e "${YELLOW}1. Open a new terminal or run 'source ~/.zshrc' (or ~/.bash_profile)${NC}"
echo -e "${YELLOW}2. Run 'nvim' to start Neovim${NC}"
echo -e "${YELLOW}3. Lazy.nvim will automatically install all plugins on first launch${NC}"
echo ""
echo -e "${GREEN}Happy coding with Neovim! 🎉${NC}"
