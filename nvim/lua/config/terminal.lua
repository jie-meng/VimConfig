-- ============================================================================
-- Terminal Utilities - Common functions for sending commands to terminal
-- ============================================================================

local M = {}

-- Find or show the terminal buffer, split and show if hidden
local function get_or_show_terminal()
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
    vim.cmd("split")
    vim.api.nvim_set_current_buf(term_bufnr)
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

-- Send a command to the terminal and enter insert mode
function M.send_to_terminal(command)
  local job_id, _ = get_or_show_terminal()
  if not job_id then return false end
  vim.api.nvim_chan_send(job_id, command .. "\n")
  vim.cmd("startinsert")
  return true
end

return M
