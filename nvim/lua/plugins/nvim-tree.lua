-- ============================================================================
-- File Explorer (nvim-tree) - replaces NERDTree
-- ============================================================================

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  keys = {
    { "<Leader>w", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
    { "<space>j", ":NvimTreeFindFile<CR>", desc = "Find current file in tree" },
  },
  config = function()
    -- Disable netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      hijack_cursor = false, -- Don't move cursor to tree when opening
      view = {
        width = 40,
        side = "left",
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "",
            modified = "●",
            folder = {
              arrow_closed = "▶",
              arrow_open = "▼",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { "*.pyc", "*.o", "*.obj", "*.exe", "*.class", ".DS_Store", "*.meta" },
      },
      actions = {
        change_dir = {
          enable = true,
          global = true,
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,  -- Don't change working directory when focusing files
      },
      git = {
        enable = true,
        ignore = false,
      },
    })

    -- Auto open nvim-tree when starting nvim
    local function open_nvim_tree(data)
      -- buffer is a directory
      local directory = vim.fn.isdirectory(data.file) == 1

      if not directory then
        return
      end

      -- change to the directory
      vim.cmd.cd(data.file)

      -- open the tree
      require("nvim-tree.api").tree.open()
      
      -- Move focus back to the main window
      vim.cmd("wincmd p")
    end

    vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

    -- Auto open when no files specified
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if vim.fn.argc() == 0 and not vim.g.in_pager_mode then
          require("nvim-tree.api").tree.open()
          -- Move focus back to the main window after opening tree
          vim.schedule(function()
            vim.cmd("wincmd p")
          end)
        end
      end
    })

    -- Close nvim-tree if it's the last window
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.fn.winnr('$') == 1 and vim.bo.filetype == "NvimTree" then
          vim.cmd("quit")
        end
      end
    })
  end,
}
