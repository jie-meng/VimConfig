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
    -- Custom highlights for better visibility
    visual = {
      bg = "#4c566a",
      fg = "#eceff4",
      bold = true,
    },
    search = {
      bg = "#ebcb8b",
      fg = "#2e3440", 
      bold = true,
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
  init = function()
    -- Setup which-key group for Avante (如果使用 which-key)
    if pcall(require, "which-key") then
      require("which-key").add({
        { "<Space>c", group = "Avante AI Assistant" }
      })
    end
    
    -- Improve Visual mode selection visibility in Avante windows
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "Avante*",
      callback = function()
        -- Set better Visual mode highlighting for Avante buffers
        vim.api.nvim_set_hl(0, "Visual", { 
          bg = "#4c566a",  -- A more contrasting blue-gray
          fg = "#eceff4",  -- Light foreground for better contrast
          bold = true 
        })
        -- Also set Search highlight for better findability
        vim.api.nvim_set_hl(0, "Search", { 
          bg = "#ebcb8b", 
          fg = "#2e3440", 
          bold = true 
        })
        -- Improve IncSearch (incremental search) highlighting
        vim.api.nvim_set_hl(0, "IncSearch", { 
          bg = "#d08770", 
          fg = "#2e3440", 
          bold = true 
        })
      end,
    })
    
    vim.api.nvim_create_autocmd("User", {
      pattern = "AvanteRequest",
      callback = function()
        vim.cmd("silent! wa")
        
        local refreshed = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and not vim.api.nvim_buf_get_option(buf, 'modified') then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" and vim.fn.filereadable(name) == 1 then
              vim.api.nvim_buf_call(buf, function()
                vim.cmd('checktime')
              end)
              refreshed = refreshed + 1
            end
          end
        end
        
        vim.notify(
          string.format("Pre-edit: Saved all files + refreshed %d buffers", refreshed),
          vim.log.levels.INFO,
          { timeout = 1500 }
        )
      end,
    })
  end,
  keys = {
    {
      "<Leader>are",
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
      "<Leader>arc",
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
