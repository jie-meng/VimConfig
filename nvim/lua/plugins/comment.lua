-- ============================================================================
-- Comment Plugin - replaces nerdcommenter
-- ============================================================================

return {
  "numToStr/Comment.nvim",
  keys = {
    -- Add vim-like shortcuts similar to nerdcommenter
    { "<Leader>ci", "gcc", desc = "Comment/uncomment line", remap = true },
    { "<Leader>ci", "gc", desc = "Comment/uncomment selection", mode = "v", remap = true },
    { "<Leader>cu", "gcc", desc = "Uncomment line", remap = true },
    { "<Leader>cu", "gc", desc = "Uncomment selection", mode = "v", remap = true },
    { "<Leader>cc", "gcc", desc = "Comment line", remap = true },
    { "<Leader>cc", "gc", desc = "Comment selection", mode = "v", remap = true },
    -- Block comment shortcuts
    { "<Leader>cb", "gbc", desc = "Block comment/uncomment", remap = true },
    { "<Leader>cb", "gb", desc = "Block comment selection", mode = "v", remap = true },
  },
  config = function()
    require("Comment").setup({
      -- Add a space b/w comment and the line
      padding = true,
      -- Whether the cursor should stay at its position
      sticky = true,
      -- Lines to be ignored while (un)comment
      ignore = nil,
      -- LHS of toggle mappings in NORMAL mode
      toggler = {
        line = "gcc", -- Line-comment toggle keymap
        block = "gbc", -- Block-comment toggle keymap
      },
      -- LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        line = "gc", -- Line-comment keymap
        block = "gb", -- Block-comment keymap
      },
      -- LHS of extra mappings
      extra = {
        above = "gcO", -- Add comment on the line above
        below = "gco", -- Add comment on the line below
        eol = "gcA", -- Add comment at the end of line
      },
      -- Enable keybindings
      mappings = {
        basic = true, -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        extra = true, -- Extra mapping; `gco`, `gcO`, `gcA`
      },
      -- Function to call before (un)comment
      pre_hook = nil,
      -- Function to call after (un)comment
      post_hook = nil,
    })
  end,
}
