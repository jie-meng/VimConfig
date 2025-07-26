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
    enabled = true,
    notify = true,  -- Show notification when updates are available
    frequency = 3600, -- Check every hour
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

-- Auto-update prompt and keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyCheck",
  callback = function()
    -- Show a user-friendly update prompt
    vim.defer_fn(function()
      local lazy = require("lazy")
      local updates = lazy.stats().updates
      if updates > 0 then
        local choice = vim.fn.confirm(
          string.format("Found %d plugin updates. Update now?", updates),
          "&Yes\n&No\n&Show details", 1
        )
        if choice == 1 then
          vim.cmd("Lazy update")
        elseif choice == 3 then
          vim.cmd("Lazy")
        end
      end
    end, 1000) -- Wait 1 second after startup
  end,
})

-- Quick update keymaps
vim.keymap.set("n", "<leader>Lu", ":Lazy update<CR>", { desc = "Lazy Update" })
vim.keymap.set("n", "<leader>Ls", ":Lazy sync<CR>", { desc = "Lazy Sync" })
vim.keymap.set("n", "<leader>Lc", ":Lazy check<CR>", { desc = "Lazy Check" })
vim.keymap.set("n", "<leader>Ll", ":Lazy<CR>", { desc = "Lazy Menu" })
