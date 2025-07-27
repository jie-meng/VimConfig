-- ============================================================================
-- Lazy.nvim Plugin Manager Setup
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "gruvbox" } },
  checker = { 
    enabled = false,  -- Disable automatic update checking
    notify = false,   -- No notifications for updates
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Quick update keymaps
vim.keymap.set("n", "<leader>Lu", ":Lazy update<CR>", { desc = "Lazy Update" })
vim.keymap.set("n", "<leader>Ls", ":Lazy sync<CR>", { desc = "Lazy Sync" })
vim.keymap.set("n", "<leader>Lc", ":Lazy check<CR>", { desc = "Lazy Check" })
vim.keymap.set("n", "<leader>Ll", ":Lazy<CR>", { desc = "Lazy Menu" })
