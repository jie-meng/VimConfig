-- ============================================================================
-- GitHub Copilot - AI pair programming (basic auto-completion only)
-- ============================================================================

-- Function to reset Copilot suggestion highlight
local function reset_copilot_suggestion_highlight()
  vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
    fg = "#808080", -- Gray color for suggestions
    italic = true 
  })
end

return {
  -- GitHub Copilot for code completion (basic functionality only)
  {
    "zbirenbaum/copilot.lua",
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
            accept = false,  -- Disable default Tab mapping
            accept_word = false,
            accept_line = false,
            next = "<C-.>",
            prev = "<C-,>",
            dismiss = "<C-/>",
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
      
      -- Set up custom highlight for Copilot suggestions
      reset_copilot_suggestion_highlight()
      
      -- Smart Tab mapping: accept Copilot suggestion if available, otherwise indent
      vim.keymap.set("i", "<Tab>", function()
        local copilot = require("copilot.suggestion")
        if copilot.is_visible() then
          copilot.accept()
          return ""  -- Return empty string to prevent further processing
        else
          -- Check if completion menu is visible
          if vim.fn.pumvisible() == 1 then
            return "<C-n>"  -- Navigate completion menu
          else
            return "<C-t>"  -- Indent
          end
        end
      end, { expr = true, desc = "Accept Copilot or indent" })
    end,
    keys = {
      -- Basic Copilot management commands only
      { "<space>Ce", ":Copilot enable<CR>", desc = "Enable Copilot" },
      { "<space>Cu", ":Copilot setup<CR>", desc = "Copilot setup" },
      { "<space>Ca", ":Copilot auth<CR>", desc = "Copilot auth" },
      { "<space>Co", ":Copilot signout<CR>", desc = "Copilot sign out" },
      { "<space>Cp", ":Copilot panel<CR>", desc = "Copilot panel" },
      { "<space>Cd", ":Copilot disable<CR>", desc = "Disable Copilot" },
      { "<space>Cs", ":Copilot status<CR>", desc = "Copilot status" },
    },
  },
}