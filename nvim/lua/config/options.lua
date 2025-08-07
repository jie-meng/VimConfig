-- ============================================================================
-- Basic Options Configuration
-- ============================================================================

local opt = vim.opt

-- Global settings
opt.nu = true
opt.wrap = false
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.background = "dark"
opt.hlsearch = true
opt.compatible = false
opt.backspace = {"indent", "eol", "start"}
opt.smartindent = true
opt.wildignore:append({"*.pyc", "*.o", "*.obj", "*.exe", "*.class", "*.DS_Store", "*.meta"})
opt.hidden = true
-- opt.ignorecase = true

-- Performance enhancement
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.lazyredraw = true
opt.updatetime = 300

-- Enable true color support
opt.termguicolors = true

-- Terminal
opt.splitbelow = true

-- Font (for GUI)
if vim.fn.has("gui_running") then
    if vim.fn.has("macunix") then
        opt.guifont = "Monaco:h12"
    elseif vim.fn.has("unix") then
        opt.guifont = "Ubuntu Mono 12"
    end
end

-- Cursor line and column
opt.cursorline = true
opt.cursorcolumn = true

-- Completion options
opt.completeopt = {"menuone", "noinsert", "noselect", "preview"}

-- Sign column
opt.signcolumn = "yes"

-- Mouse support
opt.mouse = "a"

-- Line numbers
opt.number = true
opt.relativenumber = false

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- ============================================================================
-- TreeSitter Invalid end_col Error Fix
-- ============================================================================
-- HACK: Workaround for TreeSitter highlighter 'Invalid end_col' errors
--
-- This is a known issue in Neovim since 2020 where TreeSitter's highlighter
-- miscalculates column positions in certain edge cases:
-- - When tab characters are used (byte offset vs display column mismatch)
-- - During line deletion/editing (stale position references)
-- - When nodes end at column 0
--
-- The error manifests as a popup loop that can cause data loss by preventing
-- normal editor operations. This wrapper catches and suppresses these specific
-- errors while allowing other errors to propagate normally.
--
-- This is a temporary fix until the upstream issue is resolved in Neovim core.
-- Track progress at: https://github.com/neovim/neovim/issues/29550
--
-- To remove this hack: Delete this entire block when the issue is fixed upstream
vim.defer_fn(function()
  local ok, ts_highlight = pcall(require, 'vim.treesitter.highlighter')
  if ok and ts_highlight.new then
    local old_new = ts_highlight.new
    ts_highlight.new = function(...)
      local highlighter = old_new(...)
      local old_on_line = highlighter.on_line
      highlighter.on_line = function(self, ...)
        local ok_inner, result = pcall(old_on_line, self, ...)
        if not ok_inner then
          local err = tostring(result)
          if err:match("Invalid end_col") then
            -- Suppress Invalid end_col errors
            return
          else
            -- Re-raise other errors
            error(result)
          end
        end
        return result
      end
      return highlighter
    end
  end
end, 0)
