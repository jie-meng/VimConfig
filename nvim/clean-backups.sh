#!/bin/bash

# ============================================================================
# Clean nvim configuration backups
# This script removes all backup directories created by sync-from-system.sh
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine system config directory (same logic as sync-to-system.sh)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SYSTEM_CONFIG_DIR="$HOME/.config"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    SYSTEM_CONFIG_DIR="$HOME/.config"
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}Cleaning nvim configuration backups...${NC}"
echo -e "${YELLOW}Searching in: $SYSTEM_CONFIG_DIR${NC}"

# Find all backup directories matching the pattern created by sync-to-system.sh
BACKUP_DIRS=$(find "$SYSTEM_CONFIG_DIR" -maxdepth 1 -type d -name "nvim.backup.*" 2>/dev/null || true)

if [ -z "$BACKUP_DIRS" ]; then
    echo -e "${GREEN}No backup directories found.${NC}"
    exit 0
fi

echo -e "${YELLOW}Found backup directories:${NC}"
echo "$BACKUP_DIRS" | while read -r dir; do
    echo -e "  ${YELLOW}$(basename "$dir")${NC}"
done

echo ""
read -p "Do you want to delete all these backup directories? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Deleting backup directories...${NC}"
    
    DELETED_COUNT=0
    echo "$BACKUP_DIRS" | while read -r dir; do
        if [ -d "$dir" ]; then
            echo -e "  ${RED}Deleting: $(basename "$dir")${NC}"
            rm -rf "$dir"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
    done
    
    echo -e "${GREEN}✓ All backup directories have been deleted!${NC}"
else
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi
