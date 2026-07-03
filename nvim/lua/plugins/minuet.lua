-- ============================================================================
-- Minuet AI - Local AI code completion with Llama.cpp
-- ============================================================================

return {
  "milanglacier/minuet-ai.nvim",
  event = "VeryLazy",
  config = function()
    local provider = require("config.ai_completion_provider")
    local is_active = provider.is_enabled("minuet")

    if not is_active then
      return
    end

    require("minuet").setup({
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<C-l>",
          accept_line = false,
          accept_n_lines = false,
          prev = "<C-->",
          next = "<C-=>",
          dismiss = "<C-i>",
        },
      },
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 512,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Llama.cpp",
          end_point = "http://localhost:8012/v1/completions",
          model = "PLACEHOLDER",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
          template = {
            prompt = function(context_before_cursor, context_after_cursor, _)
              return "<|fim_prefix|>"
                .. context_before_cursor
                .. "<|fim_suffix|>"
                .. context_after_cursor
                .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },
      },
    })
  end,
}
