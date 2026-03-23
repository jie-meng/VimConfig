-- ============================================================================
-- opencode.nvim - OpenCode AI assistant integration
-- https://github.com/nickjvandyke/opencode.nvim
-- Requires: `opencode` CLI installed and run with `--port` flag
-- ============================================================================

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- opencode server is started automatically via the embedded terminal
      -- Run `opencode --port` manually if you want to manage it yourself
    }

    -- Required for auto-reloading files edited by opencode
    vim.o.autoread = true

    -- Toggle opencode terminal panel
    vim.keymap.set({ "n", "t" }, "<Space>ot", function()
      require("opencode").toggle()
    end, { desc = "OpenCode: Toggle panel" })

    -- Ask opencode about current context (visual selection or cursor position)
    vim.keymap.set({ "n", "x" }, "<Space>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "OpenCode: Ask about current context" })

    -- Open prompt/command selector
    vim.keymap.set({ "n", "x" }, "<Space>os", function()
      require("opencode").select()
    end, { desc = "OpenCode: Select prompt or command" })

    -- Operator: send motion/range to opencode
    vim.keymap.set({ "n", "x" }, "<Space>oo", function()
      return require("opencode").operator("@this ")
    end, { desc = "OpenCode: Send motion to opencode", expr = true })

    -- Line operator shortcut: send current line
    vim.keymap.set("n", "<Space>ol", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "OpenCode: Send current line", expr = true })

    -- Scroll opencode panel up/down without leaving editor
    vim.keymap.set("n", "<Space>ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "OpenCode: Scroll up" })

    vim.keymap.set("n", "<Space>od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "OpenCode: Scroll down" })

    -- Session management
    vim.keymap.set("n", "<Space>on", function()
      require("opencode").command("session.new")
    end, { desc = "OpenCode: New session" })

    vim.keymap.set("n", "<Space>oi", function()
      require("opencode").command("session.interrupt")
    end, { desc = "OpenCode: Interrupt" })

    vim.keymap.set("n", "<Space>oc", function()
      require("opencode").command("session.compact")
    end, { desc = "OpenCode: Compact session (reduce context)" })
  end,
}
