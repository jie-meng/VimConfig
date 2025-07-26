-- ============================================================================
-- Comment Plugin - replaces nerdcommenter
-- ============================================================================

return {
  "numToStr/Comment.nvim",
  keys = {
    -- Use same shortcut as .vimrc: \c<space> for line comment toggle
    { "\\c<space>", "gcc", desc = "Toggle line comment", remap = true },
    { "\\c<space>", "gc", desc = "Toggle line comment", mode = "v", remap = true },
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
        line = "gcc", -- Line-comment toggle keymap (used by \c<space>)
        block = nil, -- Disable block comment toggle
      },
      -- LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        line = "gc", -- Line-comment keymap (used by \c<space> in visual mode)
        block = nil, -- Disable block comment
      },
      -- Disable extra mappings
      extra = {},
      -- Enable keybindings
      mappings = {
        basic = true, -- Enable basic mappings for gcc and gc
        extra = false, -- Disable extra mappings
      },
      -- Function to call before (un)comment
      pre_hook = nil,
      -- Function to call after (un)comment
      post_hook = nil,
    })
  end,
}
