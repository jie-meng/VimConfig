-- ============================================================================
-- GitHub Copilot - AI pair programming with Chat support
-- ============================================================================

return {
  -- Main Copilot plugin
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<Tab>",
            accept_word = false,
            accept_line = false,
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-l>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })
    end,
  },
  
  -- Copilot Chat plugin
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = false,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, 
      { "nvim-lua/plenary.nvim" }, 
    },
    config = function()
      require("CopilotChat").setup({
        debug = false, -- Enable debugging
        -- See Configuration section for rest
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

      -- Panel commands (keeping original functionality)
      { "<space>ae", ":Copilot enable<CR>", desc = "Enable Copilot" },
      { "<space>ad", ":Copilot disable<CR>", desc = "Disable Copilot" },
      { "<space>as", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>ap", ":Copilot panel<CR>", desc = "Copilot panel" },
    },
  },
}
