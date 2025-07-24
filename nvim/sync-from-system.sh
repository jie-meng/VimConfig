#!/bin/bash

# ============================================================================
# Sync nvim configuration FROM system
# This script syncs the system's nvim config back to the current project
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

echo -e "${GREEN}Syncing nvim configuration FROM system...${NC}"
echo -e "${YELLOW}From: $SYSTEM_NVIM_DIR${NC}"
echo -e "${YELLOW}To: $PROJECT_NVIM_DIR${NC}"

# Check if system config exists
if [ ! -d "$SYSTEM_NVIM_DIR" ]; then
    echo -e "${RED}System nvim configuration not found at: $SYSTEM_NVIM_DIR${NC}"
    echo -e "${YELLOW}Please run sync-to-system.sh first or create your nvim config.${NC}"
    exit 1
fi

# Create backup of current project config
if [ -d "$PROJECT_NVIM_DIR/lua" ] || [ -f "$PROJECT_NVIM_DIR/init.lua" ]; then
    BACKUP_DIR="$PROJECT_NVIM_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Creating backup at: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    if [ -f "$PROJECT_NVIM_DIR/init.lua" ]; then
        cp "$PROJECT_NVIM_DIR/init.lua" "$BACKUP_DIR/"
    fi
    if [ -d "$PROJECT_NVIM_DIR/lua" ]; then
        cp -r "$PROJECT_NVIM_DIR/lua" "$BACKUP_DIR/"
    fi
fi

# Copy configuration files (excluding certain files)
echo -e "${GREEN}Copying configuration files...${NC}"

# Copy init.lua
if [ -f "$SYSTEM_NVIM_DIR/init.lua" ]; then
    cp "$SYSTEM_NVIM_DIR/init.lua" "$PROJECT_NVIM_DIR/"
fi

# Copy lua directory
if [ -d "$SYSTEM_NVIM_DIR/lua" ]; then
    # Remove existing lua directory and copy fresh
    rm -rf "$PROJECT_NVIM_DIR/lua"
    cp -r "$SYSTEM_NVIM_DIR/lua" "$PROJECT_NVIM_DIR/"
fi

# Copy other important config files if they exist
for file in "lazy-lock.json" ".luarc.json" "stylua.toml"; do
    if [ -f "$SYSTEM_NVIM_DIR/$file" ]; then
        cp "$SYSTEM_NVIM_DIR/$file" "$PROJECT_NVIM_DIR/"
    fi
done

# Restore sync scripts (they shouldn't be in system config)
SCRIPT_NAME="$(basename "$0")"
if [ ! -f "$PROJECT_NVIM_DIR/$SCRIPT_NAME" ]; then
    echo -e "${YELLOW}Restoring sync scripts...${NC}"
    # This script should still exist since we're running it
    # The other scripts might need to be restored from git or recreated
fi

echo -e "${GREEN}✓ Configuration synced successfully from system!${NC}"
echo -e "${YELLOW}Note: Review the changes and commit them to git if needed.${NC}"
