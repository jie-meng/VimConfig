-- ============================================================================
-- Code Formatting - replaces prettier, autopep8, clang-format
-- ============================================================================

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<Leader>fc", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format code" },
    { "<Leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format code" },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "autopep8" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      go = { "gofmt" },
      rust = { "rustfmt" },
    },
    format_on_save = function(bufnr)
      -- Disable format_on_save for specific filetypes
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters = {
      autopep8 = {
        args = { "--in-place", "--aggressive", "--aggressive", "$FILENAME" },
      },
      clang_format = {
        args = { "--style=file", "--fallback-style=Google" },
      },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
