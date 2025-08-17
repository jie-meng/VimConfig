-- =====================
-- Theme Switcher Core
-- =====================

local M = {}

-- 1. Theme list (extend as needed)
M.themes = {
  { name = "gruvbox",    lualine = "gruvbox"    },
  { name = "tokyonight", lualine = "tokyonight" },
  { name = "catppuccin", lualine = "catppuccin" },
  { name = "onedark",    lualine = "onedark"    },
  { name = "monokai-pro", lualine = "monokai-pro" },
  { name = "ayu",        lualine = "ayu"        },
  { name = "dracula",    lualine = "dracula"    },
}

-- 2. State and persistence
M.theme_file = vim.fn.stdpath('data') .. "/nvim_theme.txt"

local function read_theme_idx()
  local f = io.open(M.theme_file, "r")
  if f then
    local t = f:read("*l")
    f:close()
    for i, v in ipairs(M.themes) do if v.name == t then return i end end
  end
  return 1
end

local function write_theme_idx(idx)
  local f = io.open(M.theme_file, "w")
  if f then f:write(M.themes[idx].name) f:close() end
end

M.current_idx = read_theme_idx()

-- 3. Theme switching logic
local plugin_map = {
  gruvbox      = "gruvbox.nvim",
  tokyonight   = "tokyonight.nvim",
  catppuccin   = "catppuccin",
  onedark      = "onedark.nvim",
  ["monokai-pro"] = "monokai-pro.nvim",
  ayu          = "ayu",
  dracula      = "dracula.nvim",
}


function M.apply_theme(idx, silent, tried)
  local entry = M.themes[idx] or M.themes[1]
  tried = tried or {}
  -- Ensure theme plugin is loaded
  local plugin_name = plugin_map[entry.name]
  if plugin_name then
    require("lazy").load({ plugins = { plugin_name }, wait = true })
  end

  -- Switch colorscheme
  local ok = pcall(vim.cmd.colorscheme, entry.name)
  if not ok then
    vim.notify("Theme '" .. entry.name .. "' not installed, skipping...", vim.log.levels.WARN)
    tried[idx] = true
    -- Try the next theme that hasn't been tried yet
    for i = 1, #M.themes do
      if not tried[i] then
        return M.apply_theme(i, silent, tried)
      end
    end
    -- All themes have been tried, show error message
    vim.notify("No available colorscheme found! Please install a theme plugin.", vim.log.levels.ERROR)
    return
  end
  M.current_idx = idx
  -- Sync lualine theme
  if package.loaded["lualine"] then
    require("lualine").setup({
      options = {
        theme = entry.lualine,
        icons_enabled = false,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        globalstatus = false,
      },
    })
  end
    -- Enhance diff highlight contrast
    vim.api.nvim_set_hl(0, "DiffAdd",    { bg = "#335533", bold = true })
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#444444", bold = true })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#553333", bold = true })
    vim.api.nvim_set_hl(0, "DiffText",   { bg = "#666600", bold = true }) 
  write_theme_idx(idx)
  if not silent then
    vim.notify("Theme: " .. entry.name)
  end
end

function M.next_theme()
  local idx = M.current_idx % #M.themes + 1
  M.apply_theme(idx, false)
end

function M.prev_theme()
  local idx = (M.current_idx - 2) % #M.themes + 1
  M.apply_theme(idx, false)
end

-- 4. Keymap bindings
local function setup_keymaps()
  vim.keymap.set("n", "<leader>+", M.next_theme, { desc = "Next theme" })
  vim.keymap.set("n", "<leader>_", M.prev_theme, { desc = "Prev theme" })
end

-- 5. Auto-apply last theme on startup
vim.schedule(function()
  M.apply_theme(M.current_idx, true)
end)
setup_keymaps()

-- =====================
-- Theme Plugins (lazy.nvim)
-- =====================

return {
  -- Official theme plugins
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({})
    end,
  },
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "storm" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { flavour = "mocha", integrations = { nvimtree = true, telescope = true, gitsigns = true, treesitter = true } } },
  {
    "navarasu/onedark.nvim",
    lazy = true,
    config = function()
      require("onedark").setup {
        style = "deep"
      }
    end,
  },
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    lazy = true,
    config = function()
      require("monokai-pro").setup({
        filter = "pro",
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment = { italic = true },
          keyword = { italic = true },
          type = { italic = true },
          storageclass = { italic = true },
          structure = { italic = true },
          parameter = { italic = true },
          annotation = { italic = true },
          tag_attribute = { italic = true },
        },
      })
    end,
  },
  { "Shatur/neovim-ayu", name = "ayu", lazy = true },
  {
    "Mofiqul/dracula.nvim",
    name = "dracula.nvim",
    lazy = true,
    config = function()
      require("dracula").setup({
        overrides = {
          CursorLine = { bg = "#44475a", blend = 0 },
          CursorColumn = { bg = "#44475a", blend = 0 },
          NvimTreeFolderIcon = { fg = "#8be9fd" },
          NvimTreeFolderName = { fg = "#8be9fd" },
          NvimTreeOpenedFolderName = { fg = "#50fa7b" },
          NvimTreeRootFolder = { fg = "#ff79c6" },
          NvimTreeFileIcon = { fg = "#f8f8f2" },
        }
      })
    end,
  },
  -- Color highlighter plugin
  { "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true, RRGGBB = true, names = true,
          RRGGBBAA = false, AARRGGBB = false,
          rgb_fn = false, hsl_fn = false,
          css = false, css_fn = false,
          mode = "background", tailwind = false,
          sass = { enable = false, parsers = { "css" } },
          virtualtext = "■",
        },
        buftypes = {},
      })
    end
  },
}
