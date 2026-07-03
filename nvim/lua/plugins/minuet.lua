-- ============================================================================
-- Minuet AI - Local AI code completion with Llama.cpp
-- ============================================================================
--
-- Setup:
--   1. Install llama.cpp:  brew install llama.cpp
--   2. Start llama-server (auto-downloads model on first run):
--         llama-server \
--           -hf ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF \
--           --port 8012 -ngl 99 -fa auto -ub 1024 -b 1024 \
--           --ctx-size 0 --cache-reuse 256
--      Or use the provided launchd service for auto-start on login:
--         nvim/com.llamacpp.server.plist -> ~/Library/LaunchAgents/
--   3. View cached models:  llama-server --cache-list
--
-- References:
--   https://github.com/milanglacier/minuet-ai.nvim
--   https://github.com/milanglacier/minuet-ai.nvim/blob/main/recipes.md
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
      n_completions = 1, -- Recommend for local model for resource saving
      -- I recommend beginning with a small context window size and incrementally
      -- expanding it, depending on your local computing power. A context window
      -- of 512 serves as a good starting point to estimate your computing power.
      -- Once you have a reliable estimate of your local computing power,
      -- you should adjust the context window to a larger value.
      context_window = 512,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Llama.cpp",
          end_point = "http://localhost:8012/v1/completions",
          -- The model is set by the llama-cpp server and cannot be altered
          -- post-launch.
          model = "PLACEHOLDER",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
          -- Llama.cpp does not support the `suffix` option in FIM completion.
          -- Therefore, we must disable it and manually populate the special
          -- tokens required for FIM completion.
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
