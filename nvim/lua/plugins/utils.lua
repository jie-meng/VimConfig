-- ============================================================================
-- Utility Plugins - replaces various vim plugins
-- ============================================================================

return {
  -- Syntax highlighting - replaces vim-polyglot
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "lua", "vim", "vimdoc", "query",
          "python", "javascript", "typescript", "html", "css",
          "json", "yaml", "toml", "rust", "go", "java",
          "markdown", "markdown_inline"
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {},
        map_cr = true,
        pairs_map = {
          ["'"] = "'",
          ['"'] = '"',
          -- intentionally omit backtick
        },
        ignored_next_char = [=[[%w%%%'%["%.]]=],
      })
      -- Remove backtick from rules
      local npairs = require("nvim-autopairs")
      npairs.get_rule('`'):with_pair(function() return false end)
    end,
  },

  -- Surround - replaces vim-surround functionality
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Case conversion - replaces vim-caser
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
    keys = {
      "ga", -- Default invocation prefix
      { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
    },
    cmd = {
      "Subs",
      "TextCaseOpenTelescope",
      "TextCaseOpenTelescopeQuickChange",
      "TextCaseOpenTelescopeLSPChange",
      "TextCaseStartReplacingCommand",
    },
  },

  -- Tagbar replacement
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<Leader><F12>", ":AerialToggle<CR>", desc = "Toggle aerial" },
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
        },
        show_guides = true,
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
        },
      })
    end,
  },

  -- Markdown preview - replaces previm
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<Leader>m", ":MarkdownPreviewToggle<CR>", desc = "Markdown preview" },
    },
    config = function()
      if vim.fn.has("macunix") == 1 then
        vim.g.mkdp_browser = "Google Chrome"
      elseif vim.fn.has("unix") == 1 then
        vim.g.mkdp_browser = "firefox"
      end
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    keys = {
      { "<space>ae", ":Copilot enable<CR>", desc = "Copilot enable" },
      { "<space>ad", ":Copilot disable<CR>", desc = "Copilot disable" },
      { "<space>as", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>ap", ":Copilot panel<CR>", desc = "Copilot panel" },
      { "<space>au", ":Copilot setup<CR>", desc = "Copilot setup" },
      { "<space>ao", ":Copilot signout<CR>", desc = "Copilot signout" },
    },
  },

  -- Global replace - replaces greplace
  {
    "windwp/nvim-spectre",
    keys = {
      { "<space>GS", function() require("spectre").open() end, desc = "Open Spectre" },
      { "<space>GR", function() require("spectre").open_file_search() end, desc = "Search current file" },
    },
    config = function()
      require("spectre").setup({
        mapping = {
          ['toggle_line'] = {
              map = "dd",
              cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
              desc = "toggle current item"
          },
          ['enter_file'] = {
              map = "<cr>",
              cmd = "<cmd>lua require('spectre').enter_file()<CR>", 
              desc = "goto current file"
          },
          ['send_to_qf'] = {
              map = "<leader>q",
              cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
              desc = "send all item to quickfix"
          },
          ['replace_cmd'] = {
              map = "<leader>c",
              cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
              desc = "input replace vim command"
          },
          ['show_option_menu'] = {
              map = "<leader>o",
              cmd = "<cmd>lua require('spectre').show_options()<CR>",
              desc = "show option"
          },
          ['run_current_replace'] = {
              map = "<leader>rc",
              cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
              desc = "replace current line"
          },
          ['run_replace'] = {
              map = "<leader>R",
              cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
              desc = "replace all"
          },
          ['change_view_mode'] = {
              map = "<leader>v",
              cmd = "<cmd>lua require('spectre').change_view()<CR>",
              desc = "change result view mode"
          },
          ['change_replace_sed'] = {
            map = "trs",
            cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
            desc = "use sed to replace"
          },
          ['change_replace_oxi'] = {
            map = "tro",
            cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
            desc = "use oxi to replace"
          },
          ['toggle_live_update']={
            map = "tu",
            cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
            desc = "update change when vim write file."
          },
          ['toggle_ignore_case'] = {
            map = "ti",
            cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
            desc = "toggle ignore case"
          },
          ['toggle_ignore_hidden'] = {
            map = "th",
            cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
            desc = "toggle search hidden"
          },
          ['resume_last_search'] = {
            map = "<leader>l",
            cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
            desc = "resume last search before close"
          },
        },
      })
    end,
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  -- Which key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require("which-key").setup({})
    end,
  },
}
