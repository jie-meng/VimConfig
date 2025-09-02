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

local im_select_path = 'im-select'
-- Auto switch input method to English (cross-platform, only if im-select is available)
local english_input = nil
if vim.fn.has('mac') == 1 then
  english_input = 'com.apple.keylayout.ABC' -- macOS English input method ID
elseif vim.fn.has('win32') == 1 then
  english_input = '1033' -- Windows English input method (US English)
elseif vim.fn.has('unix') == 1 then
  english_input = 'xkb:us::eng' -- Common Linux English input method
end

if vim.fn.executable(im_select_path) == 1 and english_input then
  vim.api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
      vim.fn.system(im_select_path .. ' ' .. english_input)
    end,
    desc = 'Switch to English input method when entering normal mode',
  })
end