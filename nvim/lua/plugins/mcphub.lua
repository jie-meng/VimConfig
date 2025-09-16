
-- ============================================================================
-- MCPHub (context7) integration - Model Context Protocol
-- ============================================================================

return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest",  -- Installs mcp-hub node binary globally
  config = function()
    vim.keymap.set("n", "<space>Mi", function()
      vim.notify("Installing mcp-hub globally via npm...", vim.log.levels.INFO)
      local cmd = "npm install -g mcp-hub@latest"
      local job = vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("mcp-hub installation complete!", vim.log.levels.INFO)
          else
            vim.notify("Failed to install mcp-hub. Please check your npm setup.", vim.log.levels.ERROR)
          end
        end,
        stdout_buffered = true,
        stderr_buffered = true,
      })
      if job <= 0 then
        vim.notify("Failed to start npm install job.", vim.log.levels.ERROR)
      end
    end, { desc = "Install mcp-hub globally" })
    local function is_mcp_hub_installed()
      return vim.fn.executable("mcp-hub") == 1
    end

    if is_mcp_hub_installed() then
      require("mcphub").setup({
        auto_approve = true,
        servers = {
          context7 = {
            command = "npx",
            args = { "-y", "@upstash/context7-mcp" },
            env = {},
            auto_start = true,
            disabled = false,
          },
        },
        extensions = {
            avante = {
              make_slash_commands = true,
            },
            copilotchat = {
              enabled = true,
              convert_tools_to_functions = true,     -- Convert MCP tools to CopilotChat functions
              convert_resources_to_functions = true, -- Convert MCP resources to CopilotChat functions
              add_mcp_prefix = false,                -- Add "mcp_" prefix to function names
            },
        },
        ui = {
          window = {
            width = 0.8,
            height = 0.8,
            border = "rounded",
            relative = "editor",
            zindex = 50,
          },
        },
        on_error = function(err)
          vim.notify("MCPHub error: " .. tostring(err), vim.log.levels.ERROR)
        end,
      })
    end

    vim.keymap.set("n", "<space>Ms", function()
      local installed = is_mcp_hub_installed()
      local running = installed and require("mcphub").get_hub_instance() ~= nil
      local msg
      if not installed then
        msg = "mcp-hub is not installed. MCPHub features are unavailable. Please run: npm install -g mcp-hub@latest"
      else
        msg = "MCPHub status: " .. (running and "running" or "not running")
      end
      vim.notify(msg, installed and vim.log.levels.INFO or vim.log.levels.WARN)
    end, { desc = "MCPHub status" })
  end
}
