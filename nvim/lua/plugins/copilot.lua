-- ============================================================================
-- GitHub Copilot - AI pair programming (official plugin)
-- ============================================================================

-- Function to reset Copilot suggestion highlight
local function reset_copilot_suggestion_highlight()
  vim.api.nvim_set_hl(0, "CopilotSuggestion", {
    fg = "#808080",
    italic = true
  })
end

return {
  {
    "github/copilot.vim",
    event = "VeryLazy",
    config = function()
      local provider = require("config.ai_completion_provider")
      local is_active = provider.is_enabled("copilot")

      if not is_active then
        vim.g.copilot_enabled = false
        return
      end

      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = {
        ["help"] = false,
        ["gitcommit"] = false,
        ["gitrebase"] = false,
        ["hgcommit"] = false,
        ["svn"] = false,
        ["cvs"] = false,
      }

      reset_copilot_suggestion_highlight()

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.defer_fn(function()
            reset_copilot_suggestion_highlight()
          end, 100)
        end,
        desc = "Auto-reset Copilot suggestion highlight after colorscheme change"
      })

      -- Smart Tab: accept Copilot suggestion if available, otherwise normal Tab behavior
      vim.keymap.set("i", "<Tab>", function()
        local suggestion = vim.fn["copilot#GetDisplayedSuggestion"]()
        if suggestion.text ~= "" then
          return vim.fn["copilot#Accept"]("")
        elseif vim.fn.pumvisible() == 1 then
          return "<C-n>"
        else
          local sw = vim.bo.shiftwidth
          if vim.bo.expandtab then
            return string.rep(" ", sw)
          else
            return "\t"
          end
        end
      end, { expr = true, silent = true, desc = "Accept Copilot or indent at cursor" })

      vim.keymap.set("i", "<C-l>", 'copilot#Accept("")', { expr = true, replace_keycodes = false, desc = "Accept Copilot suggestion" })
      vim.keymap.set("i", "<C-.>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-,>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-/>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
    end,
    keys = {
      { "<space>Ca", ":Copilot setup<CR>", desc = "Copilot setup/auth" },
      { "<space>Cs", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>Ce", ":Copilot enable<CR>", desc = "Copilot enable" },
      { "<space>Cd", ":Copilot disable<CR>", desc = "Copilot disable" },
      { "<space>Cp", ":Copilot panel<CR>", desc = "Copilot panel" },
      { "<space>Cv", ":Copilot version<CR>", desc = "Copilot version" },
      { "<space>Ch", function()
        reset_copilot_suggestion_highlight()
        vim.notify("Copilot suggestion highlight reset", vim.log.levels.INFO)
      end, desc = "Reset Copilot suggestion highlight" },
    },
  },
}
