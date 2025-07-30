-- ============================================================================
-- Status Line (lualine) - replaces vim-airline
-- ============================================================================

return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local ok, cs = pcall(require, "plugins.colorscheme")
    if ok and cs and cs.apply_theme then
      cs.apply_theme(cs.current_idx)
    else
      require("lualine").setup({})
    end
  end,
}
