-- ============================================================================
-- Avante.nvim - AI code assistant plugin configuration (full official style)
-- ============================================================================

-- Add these environment variables to your shell configuration (~/.bashrc, ~/.zshrc, etc.):
-- export AVANTE_OPENAI_ENDPOINT=https://dashscope.aliyuncs.com/compatible-mode/v1
-- export AVANTE_OPENAI_MODEL=qwen3-coder-plus
-- export AVANTE_OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxx
-- export AVANTE_MOONSHOT_API_KEY=ms-xxxxxxxxxxxxxxxx

-- Persistence for provider and model selection
local persistence_file = vim.fn.stdpath("data") .. "/avante_settings.json"

local function save_settings(provider, model)
  local settings = {
    provider = provider,
    model = model,
    timestamp = os.time()
  }
  local file = io.open(persistence_file, "w")
  if file then
    file:write(vim.json.encode(settings))
    file:close()
  end
end

local function load_settings()
  local file = io.open(persistence_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local ok, settings = pcall(vim.json.decode, content)
    if ok and settings then
      return settings.provider, settings.model
    end
  end
  return nil, nil
end

-- Available models (official names from providers)
local AVAILABLE_MODELS = {
  "gpt-4.1",                    -- OpenAI GPT-4.1 (latest with 1M token context)
  "gpt-4o",                     -- OpenAI GPT-4 Omni (multimodal)
  "claude-4-sonnet"             -- Anthropic Claude 4 Sonnet (latest alias)
}

-- Available providers  
local AVAILABLE_PROVIDERS = {
  "copilot",
  "openai"
}

-- Load saved settings
local saved_provider, saved_model = load_settings()

local SIDEBAR_WIDTH = 30

local user_opts = {
  provider = saved_provider or "copilot",
  mode = "agentic",
  auto_suggestions_provider = saved_provider or "copilot",
  providers = {
    copilot = {
      model = (saved_provider == "copilot" and saved_model) or "gpt-4.1",
      timeout = 30000,
      extra_request_body = {
        temperature = 0.1,
        max_tokens = 8192,
      },
    },
    claude = {
      endpoint = vim.env.AVANTE_CLAUDE_ENDPOINT or "https://api.anthropic.com",
      model = vim.env.AVANTE_CLAUDE_MODEL or "claude-sonnet-4-20250514",
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 20480,
      },
    },
    openai = {
      endpoint = vim.env.AVANTE_OPENAI_ENDPOINT or "https://dashscope.aliyuncs.com/compatible-mode/v1",
      model = vim.env.AVANTE_OPENAI_MODEL or "qwen3-coder-plus",
      timeout = 30000,
      extra_request_body = {
        temperature = 0,
        max_tokens = 32768,
      },
    },
    moonshot = {
      endpoint = "https://api.moonshot.cn/v1", -- https://api.moonshot.ai/v1 for global
      model = "kimi-k2-0905-preview",
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 32768,
      }, 
    },
  },
  dual_boost = {
    enabled = false,
    first_provider = "copilot",
    second_provider = "claude",
    prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
    timeout = 60000,
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
    enable_token_counting = true,
    auto_approve_tool_permissions = false,
  },
  prompt_logger = {
    enabled = true,
    log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
    fortune_cookie_on_success = false,
    next_prompt = {
      normal = "<C-n>",
      insert = "<C-n>",
    },
    prev_prompt = {
      normal = "<C-p>",
      insert = "<C-p>",
    },
  },
  mappings = {
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    cancel = {
      normal = { "<C-c>" },
      insert = { "<C-c>" },
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      retry_user_request = "r",
      edit_user_request = "e",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "d",
      add_file = "@",
      close = { "<C-q>" },
      close_from_input = { normal = "<C-q>" },
    },
  },
  hints = { enabled = true },
  selection = {
    enabled = false,
    hint_display = "delayed",
  },
  windows = {
    position = "right",
    wrap = true,
    width = SIDEBAR_WIDTH,
    sidebar_header = {
      enabled = true,
      align = "center",
      rounded = true,
    },
    spinner = {
      editing = { "⡀", "⠄", "⠂", "⠁", "⠈", "⠐", "⠠", "⢀", "⣀", "⢄", "⢂", "⢁", "⢈", "⢐", "⢠", "⣠", "⢤", "⢢", "⢡", "⢨", "⢰", "⣰", "⢴", "⢲", "⢱", "⢸", "⣸", "⢼", "⢺", "⢹", "⣹", "⢽", "⢻", "⣻", "⢿", "⣿" },
      generating = { "·", "✢", "✳", "∗", "✻", "✽" },
      thinking = { "🤯", "🙄" },
    },
    input = {
      prefix = "> ",
      height = 16,
    },
    edit = {
      border = "rounded",
      start_insert = false,
    },
    ask = {
      floating = false,
      start_insert = false,
      border = "rounded",
      focus_on_apply = "ours",
    },
  },
  highlights = {
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  diff = {
    autojump = true,
    list_opener = "copen",
    override_timeoutlen = 500,
  },
  suggestion = {
    debounce = 600,
    throttle = 600,
  },
}

return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") == 1
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  keys = {
    {
      "<Space>cc",
      function() require("avante").toggle() end,
      desc = "Avante: Toggle",
      mode = "n",
    },
    {
      "<Space>ck",
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
      desc = "Add current buffer to Avante context",
      mode = { "n", "v" },
    },
    {
      "<Space>cs",
      function()
        vim.cmd("AvanteStop")
      end,
      desc = "Avante: Stop",
      mode = "n",
    },
    {
      "<Space>cre",
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
      "<Space>crc",
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
      "<Space>cpi",
      function()
        local config = require("avante.config")
        local current_provider = config.provider or "unknown"
        local providers = config.providers or {}
        local current_model = "unknown"
        
        if providers[current_provider] and providers[current_provider].model then
          current_model = providers[current_provider].model
        end
        
        vim.notify(
          string.format("Avante Provider: %s\nModel: %s", current_provider, current_model),
          vim.log.levels.INFO,
          { title = "Avante Model Info" }
        )
      end,
      desc = "Show current Avante provider and model info",
      mode = "n",
    },
    {
      "<Space>cps",
      function()
        vim.ui.select(AVAILABLE_PROVIDERS, {
          prompt = "Select Avante Provider:",
          format_item = function(item)
            return item:gsub("^%l", string.upper)
          end,
        }, function(choice)
          if choice then
            require("avante.config").override({ provider = choice })
            
            -- Get current model for the selected provider
            local current_config = require("avante.config")
            local current_model = "unknown"
            if current_config.providers and current_config.providers[choice] and current_config.providers[choice].model then
              current_model = current_config.providers[choice].model
            end
            
            -- Save the selection
            save_settings(choice, current_model)
            
            vim.notify(
              string.format("Switched to provider: %s (saved)", choice),
              vim.log.levels.INFO,
              { title = "Avante Provider" }
            )
          end
        end)
      end,
      desc = "Switch Avante provider",
      mode = "n",
    },
    {
      "<Space>cpm",
      function()
        local current_config = require("avante.config")
        local current_provider = current_config.provider or "unknown"
        
        -- Check if current provider is copilot
        if current_provider ~= "copilot" then
          vim.notify(
            string.format("Model switching only available for Copilot provider.\nCurrent provider: %s", current_provider),
            vim.log.levels.WARN,
            { title = "Model Switch" }
          )
          return
        end
        
        -- Get current model
        local current_model = "gpt-4.1" -- default
        if current_config.providers and current_config.providers.copilot and current_config.providers.copilot.model then
          current_model = current_config.providers.copilot.model
        end
        
        -- Filter models to only include Copilot-compatible ones
        local copilot_models = {}
        for _, model in ipairs(AVAILABLE_MODELS) do
          table.insert(copilot_models, model)
        end
        
        vim.ui.select(copilot_models, {
          prompt = string.format("Select Copilot Model (current: %s):", current_model),
          format_item = function(item)
            if item == current_model then
              return item .. " ← current"
            end
            return item
          end,
        }, function(choice)
          if choice and choice ~= current_model then
            local new_providers = vim.deepcopy(current_config.providers or {})
            if not new_providers.copilot then
              new_providers.copilot = {}
            end
            new_providers.copilot.model = choice
            
            require("avante.config").override({ 
              provider = "copilot",
              providers = new_providers 
            })
            
            -- Save the selection
            save_settings("copilot", choice)
            
            vim.notify(
              string.format("Switched Copilot model: %s → %s (saved)", current_model, choice),
              vim.log.levels.INFO,
              { title = "Copilot Model" }
            )
          elseif choice == current_model then
            vim.notify(
              string.format("Already using model: %s", current_model),
              vim.log.levels.INFO,
              { title = "Copilot Model" }
            )
          end
        end)
      end,
      desc = "Switch model (Copilot provider only)",
      mode = "n",
    },
  },
  opts = vim.tbl_deep_extend("force", user_opts, {
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
    -- Disable Avante's built-in tools to avoid conflicts with MCPHub tools
    disabled_tools = {
      "list_files",    -- Built-in file operations
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",         -- Built-in terminal access
    },
  }),
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  }
}
