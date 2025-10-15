-- ============================================================================
-- Neovim Configuration
-- ============================================================================

-- Set leader key
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.indentation")
require("config.testing")
require("config.ai_completion_provider").setup_commands()
require("config.lazy")
