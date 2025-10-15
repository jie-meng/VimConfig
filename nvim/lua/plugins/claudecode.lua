-- ============================================================================
-- Claude Code - AI pair programming with Claude
-- ============================================================================

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = true, -- Very lazy: only load when needed
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    config = true, -- Use default configuration
    keys = {
      { "<Space>c", nil, desc = "Claude Code" },
      { "<Space>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<Space>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<Space>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<Space>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<Space>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
      { "<Space>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<Space>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<Space>cs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<Space>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<Space>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      -- Update Claude CLI
      {
        "<Space>cu",
        function()
          local old_version = nil
          local new_version = nil
          
          -- Step 1: Get current version
          vim.notify("Checking current Claude Code CLI version...", vim.log.levels.INFO)
          vim.fn.jobstart("claude --version", {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data and data[1] and data[1] ~= "" then
                old_version = data[1]:match("%d+%.%d+%.%d+") or data[1]
              end
            end,
            on_exit = function(_, code)
              if code == 0 and old_version then
                vim.notify("Current version: " .. old_version, vim.log.levels.INFO)
              else
                vim.notify("Claude CLI not found, installing...", vim.log.levels.WARN)
                old_version = "not installed"
              end
              
              -- Step 2: Install/Update
              vim.notify("Running npm install...", vim.log.levels.INFO)
              vim.fn.jobstart("npm install -g @anthropic-ai/claude-code", {
                on_exit = function(_, exit_code)
                  if exit_code ~= 0 then
                    vim.notify("Claude Code CLI installation/update failed", vim.log.levels.ERROR)
                    return
                  end
                  
                  -- Step 3: Get new version
                  vim.fn.jobstart("claude --version", {
                    stdout_buffered = true,
                    on_stdout = function(_, data)
                      if data and data[1] and data[1] ~= "" then
                        new_version = data[1]:match("%d+%.%d+%.%d+") or data[1]
                      end
                    end,
                    on_exit = function()
                      if new_version then
                        if old_version == new_version then
                          vim.notify(
                            string.format("✓ Already up to date (version: %s)", new_version),
                            vim.log.levels.INFO
                          )
                        elseif old_version == "not installed" then
                          vim.notify(
                            string.format("✓ Claude Code CLI installed successfully (version: %s)", new_version),
                            vim.log.levels.INFO
                          )
                        else
                          vim.notify(
                            string.format("✓ Updated: %s → %s", old_version, new_version),
                            vim.log.levels.INFO
                          )
                        end
                      else
                        vim.notify("Installation completed but version check failed", vim.log.levels.WARN)
                      end
                    end,
                  })
                end,
                on_stdout = function(_, data)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then
                        print(line)
                      end
                    end
                  end
                end,
              })
            end,
          })
        end,
        desc = "Update Claude CLI (npm)",
      },
    },
  },
}

