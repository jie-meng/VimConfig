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

keymap.set("i", "<C-v>", "<ESC>\"+pa", { desc = "Paste from clipboard" })
keymap.set("v", "<C-c>", "\"+y", { desc = "Copy to clipboard" })
keymap.set("v", "<C-d>", "\"+d", { desc = "Cut to clipboard" })
keymap.set("n", "y", "\"+y", { desc = "Yank to system clipboard" })
keymap.set("v", "y", "\"+y", { desc = "Yank to system clipboard" })
keymap.set("n", "x", "\"+x", { desc = "Cut to system clipboard" })
keymap.set("v", "x", "\"+x", { desc = "Cut to system clipboard" })
keymap.set("n", "dd", '"+dd', { desc = "Delete line to system clipboard" })
keymap.set("n", "D", '"+D', { desc = "Delete to end of line to system clipboard" })
keymap.set("v", "d", '"+d', { desc = "Delete selection to system clipboard" })

-- Paste from system clipboard with p
keymap.set("n", "p", '"+p', { desc = "Paste from system clipboard" })
keymap.set("v", "p", '"+p', { desc = "Paste from system clipboard" })

-- Move
keymap.set("n", "mb", "^", { desc = "Move to beginning of line" })
keymap.set("n", "me", "$", { desc = "Move to end of line" })
keymap.set("v", "mb", "^", { desc = "Move to beginning of line" })
keymap.set("v", "me", "$", { desc = "Move to end of line" })
keymap.set("n", "mu", "<C-b>M", { desc = "Page up and center cursor" })
keymap.set("n", "md", "<C-f>M", { desc = "Page down and center cursor" })
keymap.set("v", "mu", "<C-b>M", { desc = "Page up and center cursor" })
keymap.set("v", "md", "<C-f>M", { desc = "Page down and center cursor" })
keymap.set("n", "mo", ":A<CR>", { desc = "Switch to alternate file" })
keymap.set("n", "mw", ":w<CR>", { desc = "Write file" })
keymap.set("n", "mr", ":e<CR>", { desc = "Reload file" })
keymap.set("n", "mq", ":q<CR>", { desc = "Quit" })
keymap.set("n", "mx", ":qa!<CR>", { desc = "Quit all" })
keymap.set("n", "mn", ":noh<CR>", { desc = "Clear search highlight" })

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

-- Tab for indenting in insert mode (only indent cursor position, not whole line)
keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"  -- Navigate completion menu
  else
    -- Insert spaces based on shiftwidth (respects expandtab setting)
    local sw = vim.bo.shiftwidth
    if vim.bo.expandtab then
      return string.rep(" ", sw)  -- Insert spaces
    else
      return "\t"  -- Insert actual tab character
    end
  end
end, { expr = true, desc = "Indent at cursor or next completion" })

keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"  -- Navigate completion menu backwards
  else
    return "<C-d>"  -- Unindent
  end
end, { expr = true, desc = "Unindent or previous completion" })

-- F4 in normal mode: Toggle quickfix window
keymap.set({"n", "v", "t"}, "<F4>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.getwininfo(win)[1].quickfix == 1 then
      vim.cmd("cclose")
      return
    end
  end
  vim.cmd("copen")
end, { desc = "Toggle quickfix window" })

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

-- Disable F1-F12 in insert mode
for i = 1, 12 do
  keymap.set("i", "<F" .. i .. ">", "<Nop>", { desc = "Disable F" .. i .. " in insert mode" })
end