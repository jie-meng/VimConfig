-- ============================================================================
-- Avante.nvim - AI code assistant plugin configuration (full official style)
-- ============================================================================

-- Add these environment variables to your shell configuration (~/.bashrc, ~/.zshrc, etc.):
-- export AVANTE_OPENAI_ENDPOINT=https://dashscope.aliyuncs.com/compatible-mode/v1
-- export AVANTE_OPENAI_MODEL=qwen3-coder-plus
-- export AVANTE_OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxx
-- export AVANTE_MOONSHOT_API_KEY=ms-xxxxxxxxxxxxxxxx

local SIDEBAR_WIDTH = 30
local RESET_CHAT_WINDOW_HEIGHT = 45
local INSTRUCTIONS_FILE = "AGENTS.md"

-- Global Avante layout reset function
_G.reset_avante_layout = function()
  -- Find the first Avante window (should be the chat window)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    
    if filetype == 'Avante' then
      -- Found Avante window, set it to fixed height
      pcall(vim.api.nvim_win_set_height, win, RESET_CHAT_WINDOW_HEIGHT)
      vim.notify("Reset Avante chat height", vim.log.levels.INFO)
      return
    end
  end
  
  vim.notify("No Avante chat window found", vim.log.levels.WARN)
end

return {
  "yetone/avante.nvim",
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config

  keys = {
    {
      "<Leader>ak",
      function()
        local avante = require("avante")
        local sidebar = avante.get()
        if not sidebar then
          require("avante.api").ask()
          sidebar = avante.get()
        end
        if sidebar and sidebar.file_selector then
          local current_file = vim.api.nvim_buf_get_name(0)
          if current_file and current_file ~= "" then
            local relative_path = require("avante.utils").relative_path(current_file)
            sidebar.file_selector:add_selected_file(relative_path)
          end
        end
      end,
      desc = "Add current file to Avante file selector",
      mode = "n",
    },
    {
      "<Leader>ave",
      function()
        local diff = vim.fn.system("git diff --cached")
        if not diff or diff == "" then
          vim.notify("No git diff found", vim.log.levels.WARN)
          return
        end

        -- Get prompt from centralized config
        local prompts = require("config.prompts")
        local prompt = prompts.get_code_review_prompt_with_diff(diff, 'en') -- English version

        require("avante.api").ask({
          question = prompt,
          win_config = { 
            position = "right",
            width = SIDEBAR_WIDTH
          }
        })
      end,
      desc = "Review current git diff with Avante (English)",
      mode = "n",
    },
    {
      "<Leader>avc",
      function()
        local diff = vim.fn.system("git diff --cached")
        if not diff or diff == "" then
          vim.notify("No git diff found", vim.log.levels.WARN)
          return
        end

        -- Get prompt from centralized config
        local prompts = require("config.prompts")
        local prompt = prompts.get_code_review_prompt_with_diff(diff, 'zh-cn') -- Chinese version

        require("avante.api").ask({
          question = prompt,
          win_config = { 
            position = "right",
            width = SIDEBAR_WIDTH
          }
        })
      end,
      desc = "Review current git diff with Avante (Chinese)",
      mode = "n",
    },
    {
      "<Leader>ae",
      function()
        _G.reset_avante_layout()
      end,
      desc = "Reset Avante window layout",
      mode = "n",
    },

  },

  opts = {
    -- Project-specific instructions file
    instructions_file = INSTRUCTIONS_FILE,
    
    -- Performance optimizations
    debug = false, -- Disable debug mode
    hints = { enabled = false }, -- Disable hints for better performance
    -- Core provider settings - optimized for speed
    provider = "copilot",
    mode = "agentic",
    auto_suggestions_provider = "copilot",
    providers = {
      copilot = {
        model = "gpt-4.1",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 32768, -- Reduce max tokens for faster generation
        },
      },
      claude = {
        endpoint = vim.env.AVANTE_CLAUDE_ENDPOINT or "https://api.anthropic.com",
        model = vim.env.AVANTE_CLAUDE_MODEL or "claude-sonnet-4-20250514",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 32768,
        },
      },
      openai = {
        endpoint = vim.env.AVANTE_OPENAI_ENDPOINT or "https://dashscope.aliyuncs.com/compatible-mode/v1",
        model = vim.env.AVANTE_OPENAI_MODEL or "qwen3-coder-plus",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 32768,
        },
      },
      moonshot = {
        endpoint = "https://api.moonshot.cn/v1", -- https://api.moonshot.ai/v1 for global
        model = "kimi-k2-0905-preview",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 32768,
        }, 
      },
    },
    behaviour = {
      auto_suggestions = true, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
      enable_token_counting = true, -- Whether to enable token counting. Default to true.
      auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
    },
    web_search_engine = {
      provider = "tavily", -- tavily, serpapi, google, kagi, brave, or searxng
      proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
    },
    prompt_logger = {
      enabled = false, -- Disable logging for performance
    },
    selection = {
      enabled = false, -- Default is true
    },
    windows = {
      width = SIDEBAR_WIDTH, -- Custom width (default is 30)
      input = {
        height = 16, -- Custom height (default is 8)
      },
      edit = {
        start_insert = false, -- Default is true
      },
      ask = {
        start_insert = false, -- Default is true
      },
    },
    mappings = {
      sidebar = {
        switch_windows = "<C-j>",
        reverse_switch_windows = "<C-k>",
      },
    },

    -- MCP Hub integration
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ""
    end,
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  }
}
