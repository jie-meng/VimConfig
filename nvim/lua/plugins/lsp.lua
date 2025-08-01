-- ============================================================================
-- LSP Configuration - replaces vim-lsp, vim-lsp-settings
-- ============================================================================

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_enable = false,
      })

      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Setup quickfix window behavior globally (like .vimrc)
      local function setup_quickfix_keymaps()
        -- Find the first normal buffer window (editor window)
        local function find_editor_window()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
            if buftype == '' then
              return win
            end
          end
          return nil
        end

        -- Close quickfix and return to editor window
        local function close_and_return()
          local editor_win = find_editor_window()
          vim.cmd("cclose")
          if editor_win and vim.api.nvim_win_is_valid(editor_win) then
            vim.api.nvim_set_current_win(editor_win)
          else
            vim.cmd("wincmd p")
          end
        end

        -- Set up key mappings for quickfix window
        vim.keymap.set("n", "q", close_and_return, { buffer = true, silent = true })
        vim.keymap.set("n", "<Esc>", close_and_return, { buffer = true, silent = true })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = setup_quickfix_keymaps,
      })

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Key mappings (same as vim config)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        
        -- Global word search in project
        vim.keymap.set("n", "gR", function()
          local word = vim.fn.expand("<cword>")
          if word == "" then
            vim.notify("No word under cursor", vim.log.levels.WARN)
            return
          end
          
          -- Use Telescope's grep_string with word boundaries
          require("telescope.builtin").grep_string({
            search = word,
            word_match = "-w", -- Use word boundaries (equivalent to \b in regex)
            prompt_title = "Global Word Search: " .. word,
            use_regex = false,
          })
        end, vim.tbl_extend("force", opts, { desc = "Global word search" }))
        
        vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
        vim.keymap.set("n", "gS", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]g", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
        vim.keymap.set("n", "<space>y", function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local line = cursor[1] - 1
          local col = cursor[2]
          local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
          
          -- Find diagnostic at cursor position
          local current_diag = nil
          for _, diag in ipairs(diagnostics) do
            if col >= diag.col and col <= diag.end_col then
              current_diag = diag
              break
            end
          end
          
          if current_diag then
            -- Copy the full diagnostic message to clipboard
            vim.fn.setreg('+', current_diag.message)
            vim.fn.setreg('"', current_diag.message)  -- Also set default register
            local severity = vim.diagnostic.severity[current_diag.severity]
            vim.notify(string.format("Copied [%s] diagnostic to clipboard", severity), vim.log.levels.INFO)
          else
            vim.notify("No diagnostic found at cursor position", vim.log.levels.WARN)
          end
        end, vim.tbl_extend("force", opts, { desc = "Copy diagnostic message" }))
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<space>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format" }))
      end

      -- Configure diagnostics (same as vim config)
      vim.diagnostic.config({
        virtual_text = false, -- Disable virtual text
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Configure signs
      local signs = { Error = "✗", Warn = "⚠", Hint = "💡", Info = "ℹ" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Setup language servers (manual control)
      local home = os.getenv("HOME")
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
              },
            },
          },
        },
        ts_ls = {},
        pyright = {},
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--completion-style=detailed",
            "--compile-commands-dir=.",
            "--query-driver=/usr/bin/*," .. home .. "/.espressif/tools/*/*/*/bin/*"
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cc", "cxx" },
        },
      }

      for server, config in pairs(servers) do
        lspconfig[server].setup(vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, config))
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
}
