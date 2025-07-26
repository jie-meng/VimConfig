-- ============================================================================
-- Indentation Configuration - Language-specific indent settings
-- ============================================================================

-- Global default settings
vim.opt.tabstop = 4        -- Size of a hard tabstop (ts)
vim.opt.shiftwidth = 4     -- Size of an indentation (sw)
vim.opt.expandtab = true   -- Always use spaces instead of tab characters (et)
vim.opt.softtabstop = 4    -- Number of spaces a tab counts for while editing (sts)
vim.opt.smartindent = true -- Smart autoindenting for new lines
vim.opt.autoindent = true  -- Copy indent from previous line

-- Language-specific indentation settings
local indent_settings = {
  -- 2-space indentation languages
  javascript = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  typescript = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  javascriptreact = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  typescriptreact = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  json = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  html = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  xml = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  css = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  scss = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  less = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  yaml = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  vue = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  svelte = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  ruby = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  sh = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true }, -- Shell scripts
  bash = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  zsh = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  vim = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  markdown = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  
  -- 4-space indentation languages
  c = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  cpp = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  python = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  lua = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  php = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  java = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  kotlin = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  cs = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true }, -- C#
  sql = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  rust = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  
  -- Tab-based languages (using real tabs)
  go = { tabstop = 4, shiftwidth = 4, softtabstop = 0, expandtab = false }, -- Go uses tabs
  makefile = { tabstop = 4, shiftwidth = 4, softtabstop = 0, expandtab = false }, -- Makefiles require tabs
}

-- Function to find project root directory
local function find_project_root()
  local current_dir = vim.fn.expand("%:p:h")
  local root_patterns = {".git", ".clang-format", ".clangd", "compile_commands.json", "CMakeLists.txt", "Makefile"}
  
  while current_dir ~= "/" do
    for _, pattern in ipairs(root_patterns) do
      local path = current_dir .. "/" .. pattern
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end
  
  return nil
end

-- Function to read clang-format configuration
local function read_clang_format_config(project_root)
  local clang_format_files = {".clang-format", "_clang-format"}
  
  for _, filename in ipairs(clang_format_files) do
    local config_path = project_root .. "/" .. filename
    if vim.fn.filereadable(config_path) == 1 then
      local content = vim.fn.readfile(config_path)
      local indent_width = nil
      local use_tabs = false
      
      for _, line in ipairs(content) do
        -- Remove leading/trailing whitespace and convert to lowercase
        local clean_line = string.lower(vim.trim(line))
        
        -- Check for IndentWidth
        local width = string.match(clean_line, "indentwidth%s*:%s*(%d+)")
        if width then
          indent_width = tonumber(width)
        end
        
        -- Check for UseTab
        if string.match(clean_line, "usetab%s*:%s*true") or 
           string.match(clean_line, "usetab%s*:%s*always") or
           string.match(clean_line, "usetab%s*:%s*forindentation") then
          use_tabs = true
        end
      end
      
      if indent_width then
        return {
          tabstop = indent_width,
          shiftwidth = indent_width,
          softtabstop = use_tabs and 0 or indent_width,
          expandtab = not use_tabs
        }
      end
    end
  end
  
  return nil
end

-- Function to read .editorconfig
local function read_editorconfig(project_root)
  local config_path = project_root .. "/.editorconfig"
  if vim.fn.filereadable(config_path) == 1 then
    local content = vim.fn.readfile(config_path)
    local in_section = false
    local section_applies = false
    local indent_size = nil
    local indent_style = nil
    local tab_width = nil
    
    for _, line in ipairs(content) do
      local clean_line = vim.trim(line)
      
      -- Skip comments and empty lines
      if clean_line == "" or string.match(clean_line, "^#") then
        goto continue
      end
      
      -- Check for section headers
      if string.match(clean_line, "^%[.+%]$") then
        local pattern = string.match(clean_line, "^%[(.+)%]$")
        -- Simple pattern matching for C/C++ files
        section_applies = string.match(pattern, "%.c$") or 
                         string.match(pattern, "%.cpp$") or 
                         string.match(pattern, "%.cc$") or 
                         string.match(pattern, "%.cxx$") or 
                         string.match(pattern, "%.h$") or 
                         string.match(pattern, "%.hpp$") or
                         pattern == "*"
        in_section = true
        goto continue
      end
      
      -- Parse properties if in applicable section
      if in_section and section_applies then
        local key, value = string.match(clean_line, "^([^=]+)=(.+)$")
        if key and value then
          key = vim.trim(string.lower(key))
          value = vim.trim(string.lower(value))
          
          if key == "indent_size" then
            indent_size = tonumber(value)
          elseif key == "indent_style" then
            indent_style = value
          elseif key == "tab_width" then
            tab_width = tonumber(value)
          end
        end
      end
      
      ::continue::
    end
    
    if indent_size and indent_style then
      local use_tabs = (indent_style == "tab")
      return {
        tabstop = tab_width or indent_size,
        shiftwidth = indent_size,
        softtabstop = use_tabs and 0 or indent_size,
        expandtab = not use_tabs
      }
    end
  end
  
  return nil
end

-- Function to get project-specific indentation settings
local function get_project_indent_settings(filetype)
  local project_root = find_project_root()
  if not project_root then
    return indent_settings[filetype]
  end
  
  -- For C/C++ files, check clang-format and editorconfig
  if filetype == "c" or filetype == "cpp" then
    local clang_format_config = read_clang_format_config(project_root)
    if clang_format_config then
      return clang_format_config
    end
    
    local editorconfig = read_editorconfig(project_root)
    if editorconfig then
      return editorconfig
    end
  end
  
  -- For other files, check editorconfig
  local editorconfig = read_editorconfig(project_root)
  if editorconfig then
    return editorconfig
  end
  
  -- Fall back to default settings
  return indent_settings[filetype]
end

-- Apply language-specific settings
for filetype, _ in pairs(indent_settings) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      local settings = get_project_indent_settings(filetype)
      if settings then
        for option, value in pairs(settings) do
          vim.opt_local[option] = value
        end
      end
    end,
  })
end

-- Debug function to show current indentation settings
local function show_indent_info()
  local ft = vim.bo.filetype
  local ts = vim.bo.tabstop
  local sw = vim.bo.shiftwidth
  local sts = vim.bo.softtabstop
  local et = vim.bo.expandtab
  
  local project_root = find_project_root()
  local config_source = "default"
  
  if project_root then
    if ft == "c" or ft == "cpp" then
      if read_clang_format_config(project_root) then
        config_source = ".clang-format"
      elseif read_editorconfig(project_root) then
        config_source = ".editorconfig"
      end
    else
      if read_editorconfig(project_root) then
        config_source = ".editorconfig"
      end
    end
  end
  
  print(string.format("FileType: %s", ft))
  print(string.format("tabstop: %d, shiftwidth: %d, softtabstop: %d, expandtab: %s", 
    ts, sw, sts, et and "true" or "false"))
  print(string.format("Config source: %s", config_source))
  if project_root then
    print(string.format("Project root: %s", project_root))
  else
    print("No project root found")
  end
end

-- Add command to check indentation settings
vim.api.nvim_create_user_command("IndentInfo", show_indent_info, {})

-- Quick commands to adjust indentation for current buffer
vim.api.nvim_create_user_command("Indent2", function()
  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.softtabstop = 2
  vim.bo.expandtab = true
  print("Set indentation to 2 spaces")
end, {})

vim.api.nvim_create_user_command("Indent4", function()
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 4
  vim.bo.expandtab = true
  print("Set indentation to 4 spaces")
end, {})

vim.api.nvim_create_user_command("IndentTabs", function()
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 0
  vim.bo.expandtab = false
  print("Set indentation to tabs")
end, {})
