-- Shared terminal state (save/restore editor position)
local M = {}

local saved_win = nil
local saved_cursor = nil

function M.save_position()
  saved_win = vim.api.nvim_get_current_win()
  saved_cursor = vim.api.nvim_win_get_cursor(saved_win)
end

function M.restore_position()
  if saved_win and vim.api.nvim_win_is_valid(saved_win) then
    vim.api.nvim_set_current_win(saved_win)
    if saved_cursor then
      pcall(vim.api.nvim_win_set_cursor, saved_win, saved_cursor)
    end
  end
end

return M
