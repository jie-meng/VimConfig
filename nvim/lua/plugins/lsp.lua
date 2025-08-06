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
      -- Initialize Mason and LSP
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_enable = false,
      })

      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Format on save with multi-language, multi-condition support
      local function format_on_save(client, bufnr)
        if not (client.supports_method and client.supports_method("textDocument/formatting")) then
          return
        end

        local util = require("lspconfig.util")
        
        -- List of condition functions, each returns true/false
        local format_conditions = {}

        -- clangd: only if .clang-format exists in project root
        table.insert(format_conditions, function()
          if client.name ~= "clangd" then return false end
          local root_dir = util.root_pattern(".clang-format")(vim.api.nvim_buf_get_name(bufnr))
          return root_dir and vim.fn.filereadable(root_dir .. "/.clang-format") == 1
        end)

        -- Add more language-specific conditions here, e.g.:
        -- table.insert(format_conditions, function()
        --   if client.name ~= "jdtls" then return false end
        --   local root_dir = util.root_pattern("pom.xml", "build.gradle")(vim.api.nvim_buf_get_name(bufnr))
        --   return root_dir ~= nil
        -- end)

        -- Enable format on save if any condition is met
        local should_format = false
        for _, condition in ipairs(format_conditions) do
          if condition() then
            should_format = true
            break
          end
        end

        if should_format then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end

      -- Utility functions for window management
      local function setup_quickfix_keymaps()
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

        local function close_and_return()
          local editor_win = find_editor_window()
          vim.cmd("cclose")
          if editor_win and vim.api.nvim_win_is_valid(editor_win) then
            vim.api.nvim_set_current_win(editor_win)
          else
            vim.cmd("wincmd p")
          end
        end

        vim.keymap.set("n", "q", close_and_return, { buffer = true, silent = true })
        vim.keymap.set("n", "<Esc>", close_and_return, { buffer = true, silent = true })
      end

      -- Global keymaps and autocmds
      vim.keymap.set("n", "<Esc>", function()
        local win = vim.api.nvim_get_current_win()
        for _, float in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local config = vim.api.nvim_win_get_config(float)
          if config.relative ~= "" and config.win == win then
            vim.api.nvim_win_close(float, true)
          end
        end
      end, { desc = "Close diagnostic float" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = setup_quickfix_keymaps,
      })

      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          local win = vim.api.nvim_get_current_win()
          pcall(function()
            for _, float in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local config = vim.api.nvim_win_get_config(float)
              if config.relative ~= "" and config.win == win then
                vim.api.nvim_win_close(float, true)
              end
            end
          end)
        end,
      })

      -- LSP attach function
      local function on_attach(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Navigation keymaps
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        
        -- Search keymaps
        vim.keymap.set("n", "gR", function()
          local word = vim.fn.expand("<cword>")
          if word == "" then
            vim.notify("No word under cursor", vim.log.levels.WARN)
            return
          end
          require("telescope.builtin").grep_string({
            search = word,
            word_match = "-w",
            prompt_title = "Global Word Search: " .. word,
            use_regex = false,
          })
        end, vim.tbl_extend("force", opts, { desc = "Global word search" }))
        
        vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
        vim.keymap.set("n", "gS", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        
        -- Diagnostic keymaps
        vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]g", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
        
        -- Diagnostic copy keymap
        vim.keymap.set("n", "<space>y", function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local line = cursor[1] - 1
          local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
          if #diagnostics > 0 then
            local messages = {}
            for _, diag in ipairs(diagnostics) do
              table.insert(messages, diag.message)
            end
            local all = table.concat(messages, "\n")
            vim.fn.setreg('+', all)
            vim.fn.setreg('"', all)
            vim.notify(string.format("Copied %d diagnostics to clipboard", #diagnostics), vim.log.levels.INFO)
          else
            vim.notify("No diagnostic found at cursor line", vim.log.levels.WARN)
          end
        end, vim.tbl_extend("force", opts, { desc = "Copy diagnostic message" }))
        
        -- Action keymaps
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<space>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format" }))

        -- Project sync keymap for Gradle/Maven/Makefile
        vim.keymap.set("n", "<space>ms", function()
          local terminal_utils = require("config.terminal")
          local cwd = vim.fn.getcwd()
          local cmd, desc
          if vim.fn.filereadable(cwd .. "/gradlew") == 1 or vim.fn.filereadable(cwd .. "/gradlew.bat") == 1 then
            cmd = "./gradlew --refresh-dependencies"
            desc = "Gradle"
          elseif vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
            cmd = "mvn dependency:resolve"
            desc = "Maven"
          else
            vim.notify("No Gradle wrapper or Maven file found in project root", vim.log.levels.WARN)
            return
          end
          vim.notify("Syncing project dependencies with " .. desc .. "...", vim.log.levels.INFO)
          terminal_utils.send_to_terminal(cmd)
        end, vim.tbl_extend("force", opts, { desc = "Sync project dependencies (Gradle/Maven)" }))

        -- Build project (auto-detect Gradle/Maven/Makefile)
        vim.keymap.set("n", "<space>mb", function()
          local cwd = vim.fn.getcwd()
          local terminal_utils = require("config.terminal")
          local cmd
          if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
            cmd = "./gradlew build"
          elseif vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
            cmd = "mvn clean install"
          elseif vim.fn.filereadable(cwd .. "/Makefile") == 1 then
            cmd = "make"
          else
            vim.notify("No Gradle, Maven or Makefile build file found", vim.log.levels.WARN)
            return
          end
          vim.notify("Building project...", vim.log.levels.INFO)
          terminal_utils.send_to_terminal(cmd)
        end, vim.tbl_extend("force", opts, { desc = "Build project (Gradle/Maven/Makefile)" }))

        -- Organize imports (LSP code action)
        vim.keymap.set("n", "<space>mo", function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
          })
        end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))

        -- Setup conditional format on save
        format_on_save(client, bufnr)
      end

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = false,
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

      -- Diagnostic signs
      local signs = { Error = "✗", Warn = "⚠", Hint = "💡", Info = "ℹ" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Language server configurations
      local home = os.getenv("HOME")
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            },
          },
        },
        ts_ls = {},
        pyright = {},
        clangd = {
          cmd = {
            "clangd",
            "--compile-commands-dir=.",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=google",
            "--query-driver=/usr/bin/clang*,/usr/bin/g*,/usr/local/bin/clang*,/usr/local/bin/g*," .. home .. "/.espressif/tools/**",
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cc", "cxx" },
        },
        -- jdtls = {},                    -- Java
        -- kotlin_language_server = {},   -- Kotlin  
      }

      -- Setup all language servers
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
