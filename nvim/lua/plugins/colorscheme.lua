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
M.project_theme_file = vim.fn.stdpath('config') .. "/project_themes.json"

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

local function get_project_root()
  local result = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " rev-parse --show-toplevel"
  )
  if vim.v.shell_error == 0 and result[1] and result[1] ~= "" then
    return result[1]
  end
  return vim.fn.getcwd()
end

local function read_project_themes()
  local f = io.open(M.project_theme_file, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  if content == "" then return {} end
  local ok, data = pcall(vim.fn.json_decode, content)
  if ok and type(data) == "table" then return data end
  return {}
end

local function write_project_themes(data)
  local f = io.open(M.project_theme_file, "w")
  if not f then return end
  -- Pretty-print: one entry per line
  local lines = {}
  for k, v in pairs(data) do
    table.insert(lines, string.format('  %s: %s', vim.fn.json_encode(k), vim.fn.json_encode(v)))
  end
  table.sort(lines)
  if #lines == 0 then
    f:write("{}\n")
  else
    f:write("{\n" .. table.concat(lines, ",\n") .. "\n}\n")
  end
  f:close()
end

function M.save_project_theme()
  local root = get_project_root()
  local theme_name = M.themes[M.current_idx].name
  local data = read_project_themes()
  data[root] = theme_name
  write_project_themes(data)
  vim.notify("Saved theme '" .. theme_name .. "' for " .. root)
end

function M.clear_project_theme()
  local root = get_project_root()
  local data = read_project_themes()
  if data[root] then
    data[root] = nil
    write_project_themes(data)
    vim.notify("Cleared theme for " .. root)
  else
    vim.notify("No project theme saved for " .. root)
  end
end

function M.clear_all_project_themes()
  write_project_themes({})
  vim.notify("Cleared all project themes")
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
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 3 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location', { require("opencode").statusline } },
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
  vim.keymap.set("n", "<leader>+",  M.next_theme,              { desc = "Next theme" })
  vim.keymap.set("n", "<leader>_",  M.prev_theme,              { desc = "Prev theme" })
  vim.keymap.set("n", "<leader>ts", M.save_project_theme,       { desc = "Save project theme" })
  vim.keymap.set("n", "<leader>tc", M.clear_project_theme,      { desc = "Clear project theme" })
  vim.keymap.set("n", "<leader>tx", M.clear_all_project_themes, { desc = "Clear all project themes" })
end

-- 5. Auto-apply last theme on startup (project-specific theme takes priority)
vim.schedule(function()
  local root = get_project_root()
  local project_themes = read_project_themes()
  local project_theme = project_themes[root]
  if project_theme then
    for i, v in ipairs(M.themes) do
      if v.name == project_theme then
        M.apply_theme(i, true)
        return
      end
    end
    vim.notify("Project theme '" .. project_theme .. "' not in theme list, using default", vim.log.levels.WARN)
  end
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
  { "catgoose/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        options = {
          parsers = {
            names = { enable = true },
            hex = {
              rgb = true,
              rrggbb = true,
              rrggbbaa = false,
              aarrggbb = false,
            },
            rgb = { enable = false },
            hsl = { enable = false },
            css = false,
            css_fn = false,
            tailwind = { enable = false },
            sass = { enable = false, parsers = { "css" } },
          },
          display = {
            mode = "background",
            virtualtext = { char = "■" },
          },
        },
        buftypes = {},
      })
    end
  },
}
