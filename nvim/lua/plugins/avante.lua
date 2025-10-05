-- ============================================================================
-- Avante.nvim - AI code assistant plugin configuration (full official style)
-- ============================================================================

-- Add these environment variables to your shell configuration (~/.bashrc, ~/.zshrc, etc.):
-- export AVANTE_OPENAI_ENDPOINT=https://dashscope.aliyuncs.com/compatible-mode/v1
-- export AVANTE_OPENAI_MODEL=qwen3-coder-plus
-- export AVANTE_OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxx
-- export AVANTE_MOONSHOT_API_KEY=ms-xxxxxxxxxxxxxxxx

local SIDEBAR_WIDTH = 30
local INSTRUCTIONS_FILE = "AGENTS.md"

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
  init = function()
    if pcall(require, "which-key") then
      require("which-key").add({
        { "<Leader>a", group = "Avante AI Assistant" }
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
    {
      "<Leader>ait",
      function()
        -- Determine project root (git top-level) or fallback to cwd
        local handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
        local git_root = nil
        if handle then
          git_root = handle:read('*l')
          handle:close()
        end
        local root = nil
        if git_root and git_root ~= '' then
          root = git_root
        else
          root = vim.fn.getcwd()
        end

  local path = root .. '/' .. INSTRUCTIONS_FILE

        -- Content to write
        local content = [[
# project instructions for myapp

## your role

you are an expert full-stack developer specializing in react, node.js, and typescript. you understand modern web development practices and have experience with our tech stack.

## your mission

help build a scalable e-commerce platform by:

- writing type-safe typescript code
- following react best practices and hooks patterns
- implementing restful apis with proper error handling
- ensuring responsive design with tailwind css
- writing comprehensive unit and integration tests

## project context

myapp is a modern e-commerce platform targeting small businesses. we prioritize performance, accessibility, and user experience.

## technology stack

- frontend: react 18, typescript, tailwind css, vite
- backend: node.js, express, prisma, postgresql
- testing: jest, react testing library, playwright
- deployment: docker, aws

## coding standards

- use functional components with hooks
- prefer composition over inheritance
- write self-documenting code with clear variable names
- add jsdoc comments for complex functions
- follow the existing folder structure and naming conventions
]]
        -- If file exists, ask before overwriting
        if vim.fn.filereadable(path) == 1 then
          local choice = vim.fn.confirm(INSTRUCTIONS_FILE .. ' already exists at ' .. path .. '\nOverwrite?', '&Yes\n&No', 2)
          if choice ~= 1 then
            vim.notify('Cancelled: ' .. INSTRUCTIONS_FILE .. ' not overwritten', vim.log.levels.INFO)
            return
          end
        end

        local f, err = io.open(path, 'w')
        if not f then
          vim.notify('Failed to write ' .. INSTRUCTIONS_FILE .. ': ' .. tostring(err), vim.log.levels.ERROR)
          return
        end
        f:write(content)
        f:close()

        vim.notify('Created ' .. INSTRUCTIONS_FILE .. ' at: ' .. path, vim.log.levels.INFO)
      end,
  desc = "Generate " .. INSTRUCTIONS_FILE .. " in project root",
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
        model = "gpt-5-mini",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.1,
          max_tokens = 20480, -- Reduce max tokens for faster generation
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
          max_tokens = 20480,
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
    behaviour = {
      auto_suggestions = false, -- Keep disabled for performance
      auto_approve_tool_permissions = false,
      enable_fastapply = true, -- Keep for faster edits
      enable_token_counting = false, -- Disable to reduce overhead
      minimize_diff = true, -- Enable minimal diff for faster processing
      support_paste_from_clipboard = false, -- Disable if not needed
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
    highlights = {
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
    -- Disable tools for better performance in legacy mode
    disabled_tools = {
      -- "list_files",    -- Built-in file operations
      -- "search_files",
      -- "read_file",
      -- "create_file",
      -- "rename_file",
      -- "delete_file",
      -- "create_dir",
      -- "rename_dir",
      -- "delete_dir",
      -- "bash",         -- Built-in terminal access
      -- "python",       -- Disable Python execution
      -- "web_search",   -- Disable web search
      -- "rag_search",   -- Disable RAG search
    },
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
