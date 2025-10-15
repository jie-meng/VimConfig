-- ============================================================================
-- AI Provider Manager - Switch between Copilot and Minuet
-- ============================================================================

local M = {}

-- Path to store the current provider choice
local state_file = vim.fn.stdpath("data") .. "/ai-provider.txt"

-- Available providers
M.providers = {
  copilot = "copilot",
  minuet = "minuet",
}

-- Get the current active provider
function M.get_current()
  local file = io.open(state_file, "r")
  if file then
    local provider = file:read("*line")
    file:close()
    -- Validate provider
    if provider == M.providers.copilot or provider == M.providers.minuet then
      return provider
    end
  end
  -- Default to copilot if no valid choice found
  return M.providers.copilot
end

-- Set the active provider
function M.set_current(provider)
  if provider ~= M.providers.copilot and provider ~= M.providers.minuet then
    vim.notify("Invalid provider: " .. provider, vim.log.levels.ERROR)
    return false
  end
  
  local file = io.open(state_file, "w")
  if file then
    file:write(provider)
    file:close()
    vim.notify("AI provider set to: " .. provider .. "\nPlease restart Neovim for changes to take effect.", vim.log.levels.INFO)
    return true
  else
    vim.notify("Failed to save provider choice", vim.log.levels.ERROR)
    return false
  end
end

-- Check if a specific provider is enabled
function M.is_enabled(provider)
  return M.get_current() == provider
end

-- Switch to the other provider
function M.toggle()
  local current = M.get_current()
  local new_provider = current == M.providers.copilot and M.providers.minuet or M.providers.copilot
  M.set_current(new_provider)
end

-- Setup commands
function M.setup_commands()
  -- Command to switch provider
  vim.api.nvim_create_user_command("AiProviderSwitch", function(opts)
    local provider = opts.args
    if provider == "" then
      M.toggle()
    else
      M.set_current(provider)
    end
  end, {
    nargs = "?",
    complete = function()
      return { M.providers.copilot, M.providers.minuet }
    end,
    desc = "Switch AI provider (copilot/minuet)"
  })
  
  -- Command to show current provider
  vim.api.nvim_create_user_command("AiProviderStatus", function()
    local current = M.get_current()
    vim.notify("Current AI provider: " .. current, vim.log.levels.INFO)
  end, {
    desc = "Show current AI provider"
  })
end

return M

