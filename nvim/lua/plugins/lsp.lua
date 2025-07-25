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

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Key mappings (same as vim config)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
        vim.keymap.set("n", "gS", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]g", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<space>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format" }))

        -- Auto show diagnostics in status line when cursor is on diagnostic position
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = bufnr,
          callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line = cursor[1] - 1
            local col = cursor[2]

            -- Get diagnostics for current line
            local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
            local current_diag = nil

            -- Find diagnostic that contains the cursor position
            for _, diag in ipairs(diagnostics) do
              if col >= diag.col and col <= diag.end_col then
                current_diag = diag
                break
              end
            end

            -- Show diagnostic message if cursor is on a diagnostic
            if current_diag then
              local severity = vim.diagnostic.severity[current_diag.severity]
              vim.api.nvim_echo({ { string.format("[%s] %s", severity, current_diag.message), "DiagnosticSign" .. severity } }, false, {})
            else
              -- Clear the command line when not on a diagnostic
              vim.api.nvim_echo({ { "", "Normal" } }, false, {})
            end
          end,
        })
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
            "--compile-commands-dir=.",
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
