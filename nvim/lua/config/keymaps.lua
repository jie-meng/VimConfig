-- ============================================================================
-- Keymaps Configuration
-- ============================================================================

local keymap = vim.keymap

-- Remap C-p to C-i (same as vim config)
keymap.set("n", "<C-p>", "<C-i>", { desc = "Jump forward" })

-- Split window
keymap.set("n", "<Space>sv", ":vsplit<CR>", { desc = "Vertical split" })
keymap.set("n", "<Space>sh", ":split<CR>", { desc = "Horizontal split" })

-- Vimdiff
keymap.set("n", "<Space>ds", ":diffthis<CR>", { desc = "Diff this" })

-- Quick edit and reload config
keymap.set("n", "<Leader><F2>", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })
keymap.set("n", "<Leader>si", ":source ~/.config/nvim/init.lua<CR>", { desc = "Reload config" })

-- Change buffer
keymap.set("n", "<Leader>[", ":bp<CR>", { desc = "Previous buffer" })
keymap.set("n", "<Leader>]", ":bn<CR>", { desc = "Next buffer" })

-- Enable clipboard
keymap.set("i", "<C-v>", "<ESC>\"+pa", { desc = "Paste from clipboard" })
keymap.set("v", "<C-c>", "\"+y", { desc = "Copy to clipboard" })
keymap.set("v", "<C-d>", "\"+d", { desc = "Cut to clipboard" })

-- Move to beginning and end of line
keymap.set("n", "mb", "^", { desc = "Move to beginning of line" })
keymap.set("n", "me", "$", { desc = "Move to end of line" })
keymap.set("v", "mb", "^", { desc = "Move to beginning of line" })
keymap.set("v", "me", "$", { desc = "Move to end of line" })

-- Alt + J/K move line (Mac symbols: ∆ = Alt+J, ˚ = Alt+K)
keymap.set("n", "∆", ":m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "˚", ":m .-2<CR>==", { desc = "Move line up" })
keymap.set("i", "∆", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
keymap.set("i", "˚", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
keymap.set("v", "∆", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "˚", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Shifting blocks visually
keymap.set("n", ">", ">>", { desc = "Indent line" })
keymap.set("n", "<", "<<", { desc = "Unindent line" })
keymap.set("v", ">", ">gv", { desc = "Indent selection" })
keymap.set("v", "<", "<gv", { desc = "Unindent selection" })

-- Tab for indenting in normal and visual mode
keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

-- Terminal
keymap.set("n", "<F2>", ":terminal<CR>", { desc = "Open terminal" })
keymap.set("t", "<F3>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable auto-insert-line after RETURN on autocomplete
keymap.set("i", "<CR>", function()
    return vim.fn.pumvisible() == 1 and "<C-Y>" or "<CR>"
end, { expr = true, desc = "Smart enter" })

-- Resize window
keymap.set("n", "<Leader>.", ":vertical resize +10<CR>", { desc = "Increase width" })
keymap.set("n", "<Leader>,", ":vertical resize -10<CR>", { desc = "Decrease width" })
keymap.set("n", "<Leader>=", ":resize +10<CR>", { desc = "Increase height" })
keymap.set("n", "<Leader>-", ":resize -10<CR>", { desc = "Decrease height" })

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search highlight
keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })

-- Better up/down
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
