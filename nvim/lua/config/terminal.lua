-- ============================================================================
-- Terminal Utilities - Common functions for sending commands to terminal
-- ============================================================================

local M = {}

-- Store previous window and cursor position (shared with plugins/terminal.lua logic)
local prev_win = nil
local prev_cursor = nil

-- Helper function: jump to the bottom-most main editor window (not treeview, not terminal)
local function goto_bottom_editor_window()
  local editor_wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    local bt = vim.api.nvim_buf_get_option(buf, "buftype")
    if bt == "" and ft ~= "NvimTree" and ft ~= "neo-tree" and ft ~= "DiffviewFiles" then
      table.insert(editor_wins, win)
    end
  end
  if #editor_wins > 0 then
    -- Select the bottom editor window
    vim.api.nvim_set_current_win(editor_wins[#editor_wins])
    return true
  end
  return false
end

-- Find or show the terminal buffer, split and show if hidden
local function get_or_show_terminal()
  -- Save current window and cursor position before opening terminal
  prev_win = vim.api.nvim_get_current_win()
  prev_cursor = vim.api.nvim_win_get_cursor(prev_win)
  
  local term_bufnr, term_winnr = nil, nil
  -- Find visible terminal window
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      term_bufnr = bufnr
      term_winnr = winnr
      break
    end
  end
  -- If not visible, find any loaded terminal buffer
  if not term_bufnr then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
        term_bufnr = bufnr
        break
      end
    end
  end
  if not term_bufnr then
    print("Please open terminal first with F2, then run commands to use your environment")
    return nil, nil
  end
  -- If terminal is hidden, split and show it
  if not term_winnr then
    goto_bottom_editor_window()
    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, term_bufnr)
    vim.api.nvim_win_set_height(0, 20)
    -- Find the window number again
    for _, winnr in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winnr) == term_bufnr then
        term_winnr = winnr
        break
      end
    end
  else
    vim.api.nvim_set_current_win(term_winnr)
  end
  local job_id = vim.api.nvim_buf_get_var(term_bufnr, "terminal_job_id")
  return job_id, term_winnr
end

-- Function to get previous window info (for F2 to return to correct position)
function M.get_prev_position()
  return prev_win, prev_cursor
end

-- Send a command to the terminal and enter insert mode
function M.send_to_terminal(command)
  local job_id, _ = get_or_show_terminal()
  if not job_id then return false end
  vim.api.nvim_chan_send(job_id, command .. "\n")
  vim.cmd("startinsert")
  return true
end

return M
