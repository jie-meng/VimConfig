-- ============================================================================
-- GitHub Copilot - AI pair programming with Chat support
-- ============================================================================

return {
  -- Official Copilot plugin
  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      -- Custom keymaps for Copilot
      -- Use the default copilot tab mapping with fallback
      vim.g.copilot_no_tab_map = false
      vim.g.copilot_assume_mapped = false
      vim.g.copilot_tab_fallback = "\t"
      
      -- Add shift-tab for unindent in insert mode
      vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })
      
      vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
      
      -- Disable Copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["*"] = false,
        ["javascript"] = true,
        ["typescript"] = true,
        ["lua"] = true,
        ["rust"] = true,
        ["c"] = true,
        ["cpp"] = true,
        ["go"] = true,
        ["python"] = true,
        ["ruby"] = true,
        ["java"] = true,
        ["c_sharp"] = true,
        ["php"] = true,
        ["shell"] = true,
        ["vim"] = true,
      }
    end,
  },
  
  -- Copilot Chat plugin
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = false,
    dependencies = {
      { "github/copilot.vim" }, 
      { "nvim-lua/plenary.nvim" }, 
    },
    config = function()
      require("CopilotChat").setup({
        debug = false, -- Enable debugging
        model = 'gpt-4.1',
        agent = 'copilot', -- Chat agent to use
        chat_autocomplete = true, -- Enable chat autocompletion
        remember_as_sticky = true, 
        window = {
          layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
          width = 0.33, -- fractional width of parent, or absolute width in columns when > 1
          height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
          -- Options below only apply to floating windows
          relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
          border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
          row = nil, -- row position of the window, default is centered
          col = nil, -- column position of the window, default is centered
          title = 'Copilot Chat', -- title of chat window
          footer = nil, -- footer of chat window
          zindex = 1, -- determines if window is on top or below other floating windows
        },
      })
    end,
    keys = {
      -- Chat commands
      { "<space>cc", ":CopilotChat<CR>", desc = "Open Copilot Chat" },
      { "<space>ce", ":CopilotChatExplain<CR>", desc = "Explain code" },
      { "<space>ct", ":CopilotChatTests<CR>", desc = "Generate tests" },
      { "<space>cf", ":CopilotChatFix<CR>", desc = "Fix code" },
      { "<space>co", ":CopilotChatOptimize<CR>", desc = "Optimize code" },
      { "<space>cd", ":CopilotChatDocs<CR>", desc = "Generate docs" },
      { "<space>cr", ":CopilotChatReview<CR>", desc = "Review code" },
      { "<space>cs", ":CopilotChatCommit<CR>", desc = "Generate commit message" },
            -- Model management
      { "<space>cm", ":CopilotChatModels<CR>", desc = "Switch Copilot Chat model" },
      { "<space>cM", function()
        local chat = require("CopilotChat")
        local config = chat.config or {}
        local current_model = config.model or "unknown"
        print("Current Copilot Chat model: " .. current_model)
      end, desc = "Show current Copilot Chat model" },

      -- Panel commands (keeping original functionality)
      { "<space>ae", ":Copilot enable<CR>", desc = "Enable Copilot" },
      { "<space>ad", ":Copilot disable<CR>", desc = "Disable Copilot" },
      { "<space>as", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>ap", ":Copilot panel<CR>", desc = "Copilot panel" },
    },
  },
}
