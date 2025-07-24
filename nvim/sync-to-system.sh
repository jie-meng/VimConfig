#!/bin/bash

# ============================================================================
# Sync nvim configuration TO system
# This script syncs the current project's nvim config to the system config directory
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NVIM_DIR="$SCRIPT_DIR"

# Determine system config directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SYSTEM_NVIM_DIR="$HOME/.config/nvim"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    SYSTEM_NVIM_DIR="$HOME/.config/nvim"
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
fi

echo -e "${GREEN}Syncing nvim configuration TO system...${NC}"
echo -e "${YELLOW}From: $PROJECT_NVIM_DIR${NC}"
echo -e "${YELLOW}To: $SYSTEM_NVIM_DIR${NC}"

# Create backup if system config exists
if [ -d "$SYSTEM_NVIM_DIR" ]; then
    BACKUP_DIR="$SYSTEM_NVIM_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Creating backup at: $BACKUP_DIR${NC}"
    mv "$SYSTEM_NVIM_DIR" "$BACKUP_DIR"
fi

# Create .config directory if it doesn't exist
mkdir -p "$(dirname "$SYSTEM_NVIM_DIR")"

# Copy configuration
echo -e "${GREEN}Copying configuration files...${NC}"
cp -r "$PROJECT_NVIM_DIR" "$SYSTEM_NVIM_DIR"

# Remove this script from the copied config (if it exists there)
if [ -f "$SYSTEM_NVIM_DIR/sync-to-system.sh" ]; then
    rm "$SYSTEM_NVIM_DIR/sync-to-system.sh"
fi
if [ -f "$SYSTEM_NVIM_DIR/sync-from-system.sh" ]; then
    rm "$SYSTEM_NVIM_DIR/sync-from-system.sh"
fi
if [ -f "$SYSTEM_NVIM_DIR/install-mac.sh" ]; then
    rm "$SYSTEM_NVIM_DIR/install-mac.sh"
fi
if [ -f "$SYSTEM_NVIM_DIR/install-ubuntu.sh" ]; then
    rm "$SYSTEM_NVIM_DIR/install-ubuntu.sh"
fi

echo -e "${GREEN}✓ Configuration synced successfully!${NC}"
echo -e "${YELLOW}Note: You may need to restart nvim or run :Lazy sync to install plugins.${NC}"

# Check if nvim is available
if command -v nvim &> /dev/null; then
    echo -e "${GREEN}Neovim is installed and ready to use!${NC}"
else
    echo -e "${RED}Neovim is not installed. Please run the appropriate install script first.${NC}"
fi
