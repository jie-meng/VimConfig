#!/bin/bash

# ============================================================================
# Minimal Neovim Installation Script for macOS
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Minimal Neovim Installation Script for macOS ===${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed. Please install Homebrew first:${NC}"
    echo -e "${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    exit 1
fi

# Install Neovim
echo -e "${GREEN}Installing Neovim...${NC}"
if brew list neovim &> /dev/null; then
    echo -e "${YELLOW}Neovim is already installed. Upgrading...${NC}"
    brew upgrade neovim
else
    brew install neovim
fi

# Install only essential dependencies for core functionality
echo -e "${GREEN}Installing essential dependencies...${NC}"

# Git (for git integration)
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Installing Git (for git plugins)...${NC}"
    brew install git
fi

# ripgrep (for search functionality)
if ! command -v rg &> /dev/null; then
    echo -e "${YELLOW}Installing ripgrep (for text search)...${NC}"
    brew install ripgrep
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

echo -e "${GREEN}✓ Minimal installation completed successfully!${NC}"
echo -e "${BLUE}=== What's included ===${NC}"
echo -e "${GREEN}✓ Neovim${NC}"
echo -e "${GREEN}✓ Git integration${NC}"
echo -e "${GREEN}✓ Text search (ripgrep)${NC}"
echo ""
echo -e "${BLUE}=== What's NOT included (install later if needed) ===${NC}"
echo -e "${YELLOW}- LSP servers (install via :Mason in nvim)${NC}"
echo -e "${YELLOW}- Code formatters (prettier, autopep8, etc.)${NC}"
echo -e "${YELLOW}- Advanced file search (fd)${NC}"
echo -e "${YELLOW}- Nerd fonts (for icons)${NC}"
echo ""
echo -e "${BLUE}=== Next Steps ===${NC}"
echo -e "${YELLOW}1. Run 'nvim' to start Neovim${NC}"
echo -e "${YELLOW}2. Use :Mason to install language servers as needed${NC}"
echo -e "${YELLOW}3. Install additional tools when you need specific features${NC}"
echo ""
echo -e "${GREEN}Happy coding with Neovim! 🎉${NC}"
