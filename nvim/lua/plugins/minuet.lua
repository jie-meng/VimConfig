-- ============================================================================
-- Minuet AI - Local AI code completion with Ollama
-- ============================================================================

return {
  "milanglacier/minuet-ai.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>Me",
      function()
        vim.g.minuet_enabled = true
        vim.notify("Minuet enabled", vim.log.levels.INFO)
      end,
      desc = "Enable Minuet",
    },
    {
      "<leader>Md",
      function()
        vim.g.minuet_enabled = false
        vim.notify("Minuet disabled", vim.log.levels.INFO)
      end,
      desc = "Disable Minuet",
    },
    {
      "<leader>Ms",
      function()
        local status = vim.g.minuet_enabled ~= false and "enabled" or "disabled"
        vim.notify("Minuet is " .. status, vim.log.levels.INFO)
      end,
      desc = "Show Minuet status",
    },
  },
  config = function()
    require("minuet").setup({
      lsp = {
        enabled_ft = { "*" },
        -- Enables automatic completion triggering using `vim.lsp.completion.enable`
        enabled_auto_trigger_ft = { "*" },
      },
      -- virtualtext = {
      --   auto_trigger_ft = { "*" }, -- '*' stands for all file types
      --   keymap = {
      --     accept = "<A-A>", -- Disable builtin, use custom Tab key below
      --     accept_line = "<A-a>",
      --     accept_n_lines = "<A-z>",
      --     prev = "<A-[>",
      --     next = "<A-]>",
      --     dismiss = "<A-e>",
      --   },
      -- },
      provider = "openai_fim_compatible",
      n_completions = 1, -- Recommend for local model for resource saving
      -- I recommend beginning with a small context window size and incrementally
      -- expanding it, depending on your local computing power. A context window
      -- of 512 serves as a good starting point to estimate your computing power.
      -- Once you have a reliable estimate of your local computing power,
      -- you should adjust the context window to a larger value.
      context_window = 512,
      provider_options = {
        openai_fim_compatible = {
          -- For Windows users, TERM may not be present in environment variables.
          -- Consider using APPDATA instead.
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:3b",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
    })
  end,
}
