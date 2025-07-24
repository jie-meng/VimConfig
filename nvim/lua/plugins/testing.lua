-- ============================================================================
-- Testing - replaces vim-test
-- ============================================================================

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Test adapters
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-go",
  },
  keys = {
    { "<space>tn", function() require("neotest").run.run() end, desc = "Test nearest" },
    { "<space>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
    { "<space>ts", function() require("neotest").run.run({ suite = true }) end, desc = "Test suite" },
    { "<space>tl", function() require("neotest").run.run_last() end, desc = "Test last" },
    { "<space>tv", function() require("neotest").output_panel.toggle() end, desc = "Test output" },
    { "<space>tc", function()
        local last_cmd = require("neotest").state.last_run_command
        if last_cmd then
          vim.fn.setreg("+", last_cmd)
          print("Copied to clipboard: " .. last_cmd)
        else
          print("No test command to copy")
        end
      end, desc = "Copy test command" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
        }),
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-go"),
      },
      output = {
        enabled = true,
        open_on_run = false,
      },
      quickfix = {
        enabled = false,
        open = false,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      icons = {
        passed = "✓",
        running = "●",
        failed = "✗",
        skipped = "○",
        unknown = "?",
      },
    })
  end,
}
