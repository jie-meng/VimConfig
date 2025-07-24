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

-- Tab spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true

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

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
