-- ============================================================================
-- Code Formatting - replaces prettier, autopep8, clang-format
-- ============================================================================

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<Leader>fc", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format code" },
  },
  config = function()
    -- Define formatting configuration for different languages
    local format_config = {
      -- C/C++ formatting with clang-format
      c_cpp = {
        filetypes = { "c", "cpp" },
        formatter = "clang_format",
        auto_format_on_save = true,
        formatter_args = { "--style=file", "--fallback-style=Google", "--assume-filename=$FILENAME" },
      },
      -- Add more language configurations here in the future
      -- python = {
      --   filetypes = { "python" },
      --   formatter = "autopep8",
      --   auto_format_on_save = false,
      --   formatter_args = { "--in-place", "--aggressive", "--aggressive", "$FILENAME" },
      -- },
    }

    -- Build formatters_by_ft from config
    local formatters_by_ft = {}
    local auto_format_filetypes = {}
    local formatters = {}

    -- Process each language configuration
    for lang_name, config in pairs(format_config) do
      -- Set formatter for each filetype
      for _, filetype in ipairs(config.filetypes) do
        formatters_by_ft[filetype] = { config.formatter }
        if config.auto_format_on_save then
          auto_format_filetypes[filetype] = true
        end
      end
      
      -- Set formatter arguments
      if config.formatter_args then
        formatters[config.formatter] = {
          args = config.formatter_args,
        }
      end
    end

    -- Add remaining formatters that are not in format_config (for manual use only)
    formatters_by_ft.lua = { "stylua" }
    formatters_by_ft.python = { "autopep8" }
    formatters_by_ft.javascript = { "prettier" }
    formatters_by_ft.typescript = { "prettier" }
    formatters_by_ft.javascriptreact = { "prettier" }
    formatters_by_ft.typescriptreact = { "prettier" }
    formatters_by_ft.css = { "prettier" }
    formatters_by_ft.scss = { "prettier" }
    formatters_by_ft.html = { "prettier" }
    formatters_by_ft.json = { "prettier" }
    formatters_by_ft.yaml = { "prettier" }
    formatters_by_ft.markdown = { "prettier" }
    formatters_by_ft.go = { "gofmt" }
    formatters_by_ft.rust = { "rustfmt" }

    -- Add remaining formatter configurations
    formatters.autopep8 = {
      args = { "--in-place", "--aggressive", "--aggressive", "$FILENAME" },
    }

    require("conform").setup({
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(bufnr)
        -- Only enable format_on_save for configured filetypes
        if auto_format_filetypes[vim.bo[bufnr].filetype] then
          return {
            timeout_ms = 500,
            lsp_fallback = true,
          }
        end
        -- Disable format_on_save for other filetypes
        return false
      end,
      formatters = formatters,
    })
  end,
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
