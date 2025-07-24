-- ============================================================================
-- GitHub Copilot - AI pair programming
-- ============================================================================

return {
  {
    "github/copilot.vim",
    config = function()
      -- Disable default tab mapping to avoid conflicts
      vim.g.copilot_no_tab_map = true
      
      -- Set up key mappings
      vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion"
      })
      
      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)', { desc = "Next Copilot suggestion" })
      vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)', { desc = "Previous Copilot suggestion" })
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)', { desc = "Dismiss Copilot suggestion" })
      
      -- Command mappings (matching original .vimrc)
      vim.keymap.set('n', '<space>ae', ':Copilot enable<CR>', { desc = "Enable Copilot" })
      vim.keymap.set('n', '<space>ad', ':Copilot disable<CR>', { desc = "Disable Copilot" })
      vim.keymap.set('n', '<space>as', ':Copilot status<CR>', { desc = "Copilot status" })
      vim.keymap.set('n', '<space>ap', ':Copilot panel<CR>', { desc = "Copilot panel" })
      vim.keymap.set('n', '<space>au', ':Copilot setup<CR>', { desc = "Copilot setup" })
      vim.keymap.set('n', '<space>ao', ':Copilot signout<CR>', { desc = "Copilot signout" })
    end,
  },
}
