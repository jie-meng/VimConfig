-- ============================================================================
-- Autocompletion - replaces asyncomplete, supertab
-- ============================================================================

return {
  "hrsh7th/nvim-cmp", 
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path", 
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "saadparwaiz1/cmp_luasnip",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
    },
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load VSCode-style snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "nvim_lua" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
      formatting = {
        format = function(entry, item)
          local icons = {
            Text = "📝",
            Method = "⚡",
            Function = "ƒ",
            Constructor = "🏗",
            Field = "🏷",
            Variable = "📦",
            Class = "🏛",
            Interface = "🔌",
            Module = "📁",
            Property = "🔧",
            Unit = "📏",
            Value = "💎",
            Enum = "📋",
            Keyword = "🔑",
            Snippet = "✂",
            Color = "🎨",
            File = "📄",
            Reference = "👀",
            Folder = "📂",
            EnumMember = "📑",
            Constant = "🔒",
            Struct = "🏗",
            Event = "⚡",
            Operator = "➕",
            TypeParameter = "📝",
          }
          item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
          item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
            nvim_lua = "[Lua]",
          })[entry.source.name]
          return item
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end,
}
