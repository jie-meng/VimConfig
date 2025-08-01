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
  { name = "molokai",    lualine = "molokai"    },
  { name = "ayu",        lualine = "ayu"        },
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
  molokai      = "molokai",
  ayu          = "ayu",
}

function M.apply_theme(idx)
  local entry = M.themes[idx] or M.themes[1]
  -- Ensure theme plugin is loaded
  local plugin_name = plugin_map[entry.name]
  if plugin_name then
    require("lazy").load({ plugins = { plugin_name }, wait = true })
  end
  -- Switch colorscheme
  local ok = pcall(vim.cmd.colorscheme, entry.name)
  if not ok then
    vim.notify("Theme '" .. entry.name .. "' not installed, skipping...", vim.log.levels.WARN)
    local next_idx = idx % #M.themes + 1
    if next_idx ~= idx then
      return M.apply_theme(next_idx)
    else
      return
    end
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
  write_theme_idx(idx)
  vim.notify("Theme: " .. entry.name)
end

function M.next_theme()
  local idx = M.current_idx % #M.themes + 1
  M.apply_theme(idx)
end

function M.prev_theme()
  local idx = (M.current_idx - 2) % #M.themes + 1
  M.apply_theme(idx)
end

-- 4. Keymap bindings
local function setup_keymaps()
  vim.keymap.set("n", "<space>tn", M.next_theme, { desc = "Next theme" })
  vim.keymap.set("n", "<space>tp", M.prev_theme, { desc = "Prev theme" })
end

-- 5. Auto-apply last theme on startup
vim.schedule(function()
  M.apply_theme(M.current_idx)
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
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "moon" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { integrations = { nvimtree = true, telescope = true, gitsigns = true, treesitter = true } } },
  { "navarasu/onedark.nvim", lazy = true },
  { "tomasr/molokai", lazy = true },
  { "Shatur/neovim-ayu", name = "ayu", lazy = true },
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
