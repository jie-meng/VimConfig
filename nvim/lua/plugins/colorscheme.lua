-- =====================
-- Theme Switcher Core
-- =====================

local M = {}

local CURSORLINE_BG = "#393a4b"
local CURSORLINE_DIM_BG = "#282a36"

-- 1. Theme list (extend as needed)
M.themes = {
   { name = "gruvbox",      lualine = "gruvbox"      },
  { name = "monokai-pro",  lualine = "monokai-pro"  },
  { name = "dracula",      lualine = "dracula"      },
  { name = "bamboo",       lualine = "bamboo"       },
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
  ["monokai-pro"] = "monokai-pro.nvim",
  dracula      = "dracula.nvim",
  bamboo       = "bamboo.nvim",
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
  
  -- Reset Copilot suggestion highlight after theme change (if Copilot is loaded)
  if package.loaded["copilot"] then
    vim.defer_fn(function()
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
        fg = "#808080", -- Gray color for suggestions
        italic = true 
      })
    end, 50)
  end 

  write_theme_idx(idx)

  if not silent then
    vim.schedule(function()
      vim.notify("Theme: " .. entry.name)
    end)
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
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    lazy = true,
    config = function()
      require("monokai-pro").setup({
        filter = "pro",
        override = function(c)
          return {
            NvimTreeFolderName = { fg = c.base.blue },
            NvimTreeOpenedFolderName = { fg = c.base.yellow },
            NvimTreeFileIcon = { fg = c.base.white },
          }
        end,
      })
    end,
  },
  {
    "Mofiqul/dracula.nvim",
    name = "dracula.nvim",
    lazy = true,
    config = function()
      require("dracula").setup({
        overrides = {
          CursorLine = { bg = CURSORLINE_BG },
          CursorColumn = { bg = CURSORLINE_BG },
          NvimTreeFolderIcon = { fg = "#8be9fd" },
          NvimTreeFolderName = { fg = "#8be9fd" },
          NvimTreeOpenedFolderName = { fg = "#50fa7b" },
          NvimTreeRootFolder = { fg = "#ff79c6" },
          NvimTreeFileIcon = { fg = "#f8f8f2" },
        }
      })
    end,
  },
  {
    "ribru17/bamboo.nvim",
    name = "bamboo.nvim",
    lazy = true,
    config = function()
      require("bamboo").setup({
        style = "vulgaris", -- Choose between 'vulgaris' (regular), 'multiplex', or 'light'
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
