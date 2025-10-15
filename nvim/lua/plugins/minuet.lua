-- ============================================================================
-- Minuet AI - Local AI code completion with Ollama
-- ============================================================================

return {
  "milanglacier/minuet-ai.nvim",
  keys = {
    { "<leader>Me", function()
      vim.g.minuet_enabled = true
      vim.notify("Minuet enabled", vim.log.levels.INFO)
    end, desc = "Enable Minuet" },
    { "<leader>Md", function()
      vim.g.minuet_enabled = false
      vim.notify("Minuet disabled", vim.log.levels.INFO)
    end, desc = "Disable Minuet" },
    { "<leader>Ms", function()
      local status = vim.g.minuet_enabled ~= false and "enabled" or "disabled"
      vim.notify("Minuet is " .. status, vim.log.levels.INFO)
    end, desc = "Show Minuet status" },
  },
  config = function()
    require('minuet').setup({
      provider = 'openai_fim_compatible',
      provider_options = {
        openai_fim_compatible = {
          api_key = 'TERM',
          end_point = 'http://localhost:11434/v1/completions',
          model = 'qwen2.5-coder:7b',
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
      context_window = 512,
      n_completions = 1,
      enabled = function()
        return vim.g.minuet_enabled ~= false
      end,
    })
  end,
}