-- ============================================================================
-- Git Integration - replaces vim-fugitive, vim-gitgutter, gv.vim
-- ============================================================================

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Navigation
          vim.keymap.set('n', 'g]', function()
            if vim.wo.diff then return 'g]' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer = bufnr, desc = "Next git hunk"})

          vim.keymap.set('n', 'g[', function()
            if vim.wo.diff then return 'g[' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer = bufnr, desc = "Previous git hunk"})

          -- Actions
          vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr, desc = "Stage hunk" })
          vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr, desc = "Reset hunk" })
          vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
          vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
          vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, { buffer = bufnr, desc = "Blame line" })
          vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle blame" })
          vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = "Diff this" })
          vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = "Diff this ~" })
          vim.keymap.set('n', '<leader>td', gs.toggle_deleted, { buffer = bufnr, desc = "Toggle deleted" })

          -- Text object
          vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr, desc = "Select hunk" })
        end
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<space>go", ":DiffviewOpen<CR>", desc = "Open diffview" },
      { "<space>gv", ":DiffviewFileHistory<CR>", desc = "File history" },
      { "<space>gf", ":DiffviewFileHistory %<CR>", desc = "File history (current file)" },
      { "<space>gp", function()
        local dir = vim.fn.expand('%:p:h')
        vim.api.nvim_feedkeys(":DiffviewFileHistory " .. dir, "n", false)
      end, desc = "File history (current directory, editable)" },
    },
  },
  {
    "tpope/vim-fugitive",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function()
          local height = math.floor(vim.o.lines * 0.25)
          vim.cmd("resize " .. height)
          vim.cmd("wincmd J")
          vim.keymap.set("n", "q", function()
            local wins = vim.api.nvim_list_wins()
            local fallback = nil
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
              local bt = vim.api.nvim_buf_get_option(buf, 'buftype')
              if bt == '' and ft ~= 'nerdtree' and ft ~= 'fugitive' and ft ~= 'qf' then
                fallback = win
                break
              end
            end
            vim.cmd("close")
            if fallback and vim.api.nvim_win_is_valid(fallback) then
              vim.api.nvim_set_current_win(fallback)
            else
              vim.cmd("wincmd p")
            end
          end, { buffer = true, silent = true })
        end,
      })
    end,
    keys = {
      { "<space>gc", ":Git commit<CR>", desc = "Git commit" },
      { "<space>gb", ":Git blame<CR>", desc = "Git blame" },
      { "<space>gm", ":Git move<CR>", desc = "Git move" },
      { "<space>gr", ":Git delete<CR>", desc = "Git delete" },
      { "<space>gs", ":Git<CR>", desc = "Git status" },
      { "<space>gd", function()
        local git_root = nil
        local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
        if handle then
          git_root = handle:read("*l")
          handle:close()
        end
        if git_root and git_root ~= "" then
          local cur_dir = vim.fn.getcwd()
          vim.cmd("cd " .. git_root)
          vim.cmd("Gvdiffsplit HEAD")
          vim.cmd("cd " .. cur_dir)
        else
          vim.notify("Not a git repository (no .git found)", vim.log.levels.WARN)
        end
      end, desc = "Git diff HEAD (safe in subdir)" },
      { "<space>gy", function()
        local diff = vim.fn.system("git diff --cached")
        if not diff or diff == "" then
          vim.notify("No staged git diff found", vim.log.levels.WARN)
          return
        end
        vim.fn.setreg('+', diff)
        vim.notify("Staged git diff copied to clipboard", vim.log.levels.INFO)
      end, desc = "Copy staged git diff to clipboard" },
    },
  },
}
