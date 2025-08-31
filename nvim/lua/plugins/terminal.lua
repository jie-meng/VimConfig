-- ============================================================================
-- Terminal Configuration - replaces vim terminal functions
-- ============================================================================

return {
  -- This is a pseudo-plugin for terminal configuration
  name = "terminal-config",
  dir = vim.fn.stdpath("config"), -- Use config directory
  config = function()
    -- Set split direction to open below current window (like vim's splitbelow)
    vim.opt.splitbelow = true
    
    -- Store terminal window height
    local default_terminal_height = 20  -- Default height
    local terminal_height = default_terminal_height  -- Current height
    
    -- Helper function to find existing terminal buffer
    local function find_terminal_buffer()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
          return buf
        end
      end
      return nil
    end
    
    -- Helper function to find terminal window
    local function find_terminal_window(term_buf)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == term_buf then
          return win
        end
      end
      return nil
    end
    
    -- Helper function to detect environment type
    local function detect_environment()
      local virtual_env = vim.env.VIRTUAL_ENV
      local conda_env = vim.env.CONDA_DEFAULT_ENV
      local idf_path = vim.env.IDF_PATH
      
      if idf_path then
        return "esp-idf", idf_path
      elseif virtual_env then
        return "venv", virtual_env
      elseif conda_env then
        return "conda", conda_env
      else
        return "normal", nil
      end
    end
    
    -- Helper function to generate activation command
    local function get_activation_command(env_type, env_path)
      local is_windows = vim.fn.has('win32') == 1
      
      if env_type == "esp-idf" then
        if is_windows then
          return string.format('"%s\\export.bat"\r', env_path)
        else
          return string.format('. "%s/export.sh"\r', env_path)
        end
      elseif env_type == "venv" then
        if is_windows then
          return string.format('"%s\\Scripts\\activate.bat"\r', env_path)
        else
          return string.format('source "%s/bin/activate"\r', env_path)
        end
      elseif env_type == "conda" then
        return string.format('conda activate %s\r', env_path)
      end
      return nil
    end
    
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

    -- Helper function to create new terminal with environment
    local function create_new_terminal()
      goto_bottom_editor_window()
      vim.cmd("split")
      vim.api.nvim_win_set_height(0, terminal_height)  -- Use stored height

      local env_type, env_path = detect_environment()
      local activation_cmd = get_activation_command(env_type, env_path)

      if activation_cmd then
        vim.cmd("terminal")
        -- Send activation command after terminal opens
        vim.defer_fn(function()
          vim.api.nvim_feedkeys(activation_cmd, "t", false)
        end, 100)
      else
        -- No special environment, create normal terminal
        vim.cmd("terminal " .. vim.o.shell)
      end

      vim.cmd("startinsert")  -- Enter insert mode automatically
    end

    -- Helper function to show existing terminal
    local function show_existing_terminal(term_buf)
      goto_bottom_editor_window()
      vim.cmd("split")
      vim.api.nvim_win_set_buf(0, term_buf)
      vim.api.nvim_win_set_height(0, terminal_height)  -- Use stored height
      vim.cmd("startinsert")  -- Enter insert mode automatically
    end
    
    -- Store previous window and cursor position
    local prev_win = nil
    local prev_cursor = nil

    -- Main toggle terminal function
    local function toggle_terminal()
      -- Always record current window and cursor before opening/showing terminal
      prev_win = vim.api.nvim_get_current_win()
      prev_cursor = vim.api.nvim_win_get_cursor(prev_win)

      local term_buf = find_terminal_buffer()

      if term_buf then
        local term_win = find_terminal_window(term_buf)

        if term_win then
          -- Terminal is visible, save height before closing
          terminal_height = vim.api.nvim_win_get_height(term_win)
          vim.api.nvim_win_close(term_win, false)
          -- Restore previous window and cursor
          if prev_win and vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
            if prev_cursor then
              pcall(vim.api.nvim_win_set_cursor, prev_win, prev_cursor)
            end
          end
        else
          -- Terminal exists but not visible, show it
          show_existing_terminal(term_buf)
        end
      else
        -- No terminal exists, create new one
        create_new_terminal()
      end
    end
    
    -- Helper function to send command to terminal
    local function send_terminal_command(command, delay)
      delay = delay or 100
      vim.defer_fn(function()
        if vim.bo.buftype == "terminal" then
          vim.api.nvim_feedkeys(command .. "\r", "t", false)
        end
      end, delay)
    end
    
    -- Key mappings
    -- F2: Toggle terminal (like original vim config)
    vim.keymap.set({"n", "v"}, "<F2>", toggle_terminal, { desc = "Toggle terminal" })

    -- F2 in terminal mode: Close terminal directly
    vim.keymap.set("t", "<F2>", function()
      local term_win = vim.api.nvim_get_current_win()
      -- Save height before closing
      terminal_height = vim.api.nvim_win_get_height(term_win)
      vim.api.nvim_win_close(term_win, false)
      
      -- First try to use saved position from terminal_utils (for test commands)
      local terminal_utils = require("config.terminal")
      local saved_win, saved_cursor = terminal_utils.get_prev_position()
      local target_win = saved_win or prev_win
      local target_cursor = saved_cursor or prev_cursor
      
      -- Restore previous window and cursor
      if target_win and vim.api.nvim_win_is_valid(target_win) then
        vim.api.nvim_set_current_win(target_win)
        if target_cursor then
          pcall(vim.api.nvim_win_set_cursor, target_win, target_cursor)
        end
      end
    end, { desc = "Close terminal" })
    
    -- Additional useful terminal keymaps
    -- Escape also exits terminal mode (alternative to F3)
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    
    -- F3: Reset terminal height to default (works in all modes)
    local function reset_terminal_height()
      local term_buf = find_terminal_buffer()
      if term_buf then
        local term_win = find_terminal_window(term_buf)
        if term_win then
          vim.api.nvim_win_set_height(term_win, default_terminal_height)
          terminal_height = default_terminal_height
          print("Terminal height reset to: " .. default_terminal_height)
        else
          print("Terminal is not visible")
        end
      else
        print("No terminal buffer found")
      end
    end
    
    vim.keymap.set({"n", "t", "v"}, "<F3>", reset_terminal_height, { desc = "Reset terminal height" })
    
    -- Easy navigation between terminal and other windows
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to down window" })
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to up window" })
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
    
    -- Quick environment check commands
    vim.keymap.set("n", "<leader>te", function()
      toggle_terminal()
      send_terminal_command("echo $VIRTUAL_ENV")
    end, { desc = "Terminal: Check Python venv" })
    
    vim.keymap.set("n", "<leader>tp", function()
      toggle_terminal()
      send_terminal_command("which python && python --version")
    end, { desc = "Terminal: Check Python path" })
    
    vim.keymap.set("n", "<leader>ti", function()
      toggle_terminal()
      send_terminal_command("echo $IDF_PATH && idf.py --version")
    end, { desc = "Terminal: Check ESP-IDF environment" })
    
    -- Debug environment variables
    vim.keymap.set("n", "<leader>td", function()
      local virtual_env = vim.env.VIRTUAL_ENV
      local conda_env = vim.env.CONDA_DEFAULT_ENV
      local idf_path = vim.env.IDF_PATH
      local idf_tools_path = vim.env.IDF_TOOLS_PATH
      local path = vim.env.PATH
      
      print("=== Environment Debug ===")
      print("VIRTUAL_ENV: " .. (virtual_env or "not set"))
      print("CONDA_DEFAULT_ENV: " .. (conda_env or "not set"))
      print("IDF_PATH: " .. (idf_path or "not set"))
      print("IDF_TOOLS_PATH: " .. (idf_tools_path or "not set"))
      print("PATH contains venv: " .. (path and path:find("venv") and "yes" or "no"))
      print("PATH contains esp: " .. (path and path:find("esp") and "yes" or "no"))
      print("Current shell: " .. vim.o.shell)
      
      toggle_terminal()
      send_terminal_command("env | grep -E '(VIRTUAL_ENV|CONDA|IDF_|ESP_|PATH)'", 200)
    end, { desc = "Terminal: Debug environment" })
    
    -- Terminal autocmds setup
    local function setup_terminal_autocmds()
      local terminal_group = vim.api.nvim_create_augroup("Terminal", { clear = true })
      
      -- Start in insert mode only when opening a new terminal
      vim.api.nvim_create_autocmd("TermOpen", {
        group = terminal_group,
        callback = function()
          vim.cmd("startinsert")
        end
      })

      -- Remove line numbers and other UI elements in terminal
      vim.api.nvim_create_autocmd("TermOpen", {
        group = terminal_group,
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
        end
      })

      -- Reset terminal height when terminal buffer is deleted (Ctrl-D)
      vim.api.nvim_create_autocmd("BufDelete", {
        group = terminal_group,
        pattern = "term://*",
        callback = function()
          terminal_height = default_terminal_height  -- Reset to default height
        end
      })
    end
    
    -- Initialize autocmds
    setup_terminal_autocmds()
  end,
}
