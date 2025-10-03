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
          keymap = {
            open = "<M-CR>"  -- Only keep the customized keymap
          },
        },
        suggestion = {
          auto_trigger = true,  -- Keep: different from default (false)
          keymap = {
            accept = false,  -- Keep: custom Tab mapping setup
            next = "<C-.>",   -- Keep: custom keymap
            prev = "<C-,>",   -- Keep: custom keymap
            dismiss = "<C-/>", -- Keep: custom keymap
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
      })
      
      -- Set up custom highlight for Copilot suggestions
      reset_copilot_suggestion_highlight()
      
      -- Auto-reset Copilot highlight when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Delay the reset to ensure the new colorscheme is fully applied
          vim.defer_fn(function()
            reset_copilot_suggestion_highlight()
          end, 100)
        end,
        desc = "Auto-reset Copilot suggestion highlight after colorscheme change"
      })
      
      -- Smart Tab mapping: accept Copilot suggestion if available, otherwise indent at cursor
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
            -- Insert spaces based on shiftwidth at cursor position (not whole line)
            local sw = vim.bo.shiftwidth
            if vim.bo.expandtab then
              return string.rep(" ", sw)  -- Insert spaces
            else
              return "\t"  -- Insert actual tab character
            end
          end
        end
      end, { expr = true, desc = "Accept Copilot or indent at cursor" })
    end,
    keys = {
      -- Basic Copilot management commands only
      { "<space>Ca", ":Copilot auth<CR>", desc = "Copilot auth" },
      { "<space>Ci", ":Copilot auth info<CR>", desc = "Copilot auth info" },
      { "<space>Co", ":Copilot auth signout<CR>", desc = "Copilot sign out" },
      { "<space>Cp", ":Copilot panel<CR>", desc = "Copilot panel" },
      { "<space>Cs", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>Ch", function()
        reset_copilot_suggestion_highlight()
        vim.notify("Copilot suggestion highlight reset", vim.log.levels.INFO)
      end, desc = "Reset Copilot suggestion highlight" },
    },
  },
}