
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
      if not installed then
        vim.notify("mcp-hub is not installed. Please run: npm install -g mcp-hub@latest", vim.log.levels.WARN)
        return
      end
      
      local hub_ready = false
      pcall(function()
        local hub = require("mcphub").get_hub_instance()
        hub_ready = hub and hub:is_ready()
      end)
      
      local msg = "MCPHub status: " .. (hub_ready and "running" or "not ready")
      vim.notify(msg, vim.log.levels.INFO)
    end, { desc = "MCPHub status" })

    vim.keymap.set("n", "<space>Mh", function()
      local installed = is_mcp_hub_installed()
      if not installed then
        vim.notify("mcp-hub is not installed", vim.log.levels.WARN)
        return
      end
      
      pcall(function()
        vim.cmd("MCPHub")
      end)
    end, { desc = "Open MCPHub UI" })

    vim.keymap.set("n", "<space>Mr", function()
      local installed = is_mcp_hub_installed()
      if not installed then
        vim.notify("mcp-hub is not installed", vim.log.levels.WARN)
        return
      end
      
      vim.notify("To restart MCPHub, please restart Neovim or use :Lazy reload mcphub.nvim", vim.log.levels.INFO)
    end, { desc = "Restart MCPHub info" })

    vim.keymap.set("n", "<space>Mc", function()
      local config_path = vim.fn.expand("~/.config/mcphub/servers.json")
      
      -- Create config directory if it doesn't exist
      local config_dir = vim.fn.fnamemodify(config_path, ":h")
      if vim.fn.isdirectory(config_dir) == 0 then
        vim.fn.mkdir(config_dir, "p")
        vim.notify("Created MCPHub config directory: " .. config_dir, vim.log.levels.INFO)
      end
      
      -- Create default config file if it doesn't exist
      if vim.fn.filereadable(config_path) == 0 then
        local default_config = vim.fn.json_encode({
          servers = {
            context7 = {
              command = "npx",
              args = { "-y", "@upstash/context7-mcp" },
              env = {},
              disabled = false
            },
            playwright = {
              command = "npx", 
              args = { "-y", "@playwright/mcp" },
              env = {},
              disabled = false
            }
          }
        })
        vim.fn.writefile(vim.split(default_config, "\n"), config_path)
        vim.notify("Created default MCPHub config: " .. config_path, vim.log.levels.INFO)
      end
      
      -- Open the config file
      vim.cmd("edit " .. config_path)
      vim.notify("Opened MCPHub config: " .. config_path, vim.log.levels.INFO)
    end, { desc = "Open MCPHub config file" })
  end
}
