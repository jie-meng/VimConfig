-- ============================================================================
-- Testing - replaces vim-test
-- ============================================================================

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
    print("Please open terminal first with F2, then run tests to use your environment")
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
local function send_to_terminal(command)
  local job_id, _ = get_or_show_terminal()
  if not job_id then return end
  vim.api.nvim_chan_send(job_id, command .. "\n")
  vim.cmd("startinsert")
end

-- Find the nearest pytest function name above the cursor
local function find_nearest_pytest_func()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    local name = string.match(line, "^%s*def%s+(test_[%w_]+)")
    if name then return name end
  end
  return nil
end

-- Build pytest command for different modes
local function build_python_test_cmd(mode)
  local cwd = vim.fn.getcwd()
  local file = vim.fn.expand("%")
  if mode == "nearest" then
    local func_name = find_nearest_pytest_func()
    if func_name then
      return string.format("cd %s && PYTHONPATH=%s pytest %s::%s -v", cwd, cwd, file, func_name)
    else
      return string.format("cd %s && PYTHONPATH=%s pytest %s -v", cwd, cwd, file)
    end
  elseif mode == "file" then
    return string.format("cd %s && PYTHONPATH=%s pytest %s -v", cwd, cwd, file)
  elseif mode == "suite" then
    return string.format("cd %s && PYTHONPATH=%s pytest -v", cwd, cwd)
  end
end

-- Find the nearest jest test name above the cursor
local function find_nearest_jest_test()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    -- Match test('desc', it('desc', test("desc", it("desc",
    local name = line:match("[%s%(]test%s*%(%s*['\"](.-)['\"]") or line:match("[%s%(]it%s*%(%s*['\"](.-)['\"]")
    if name then return name end
  end
  return nil
end

-- Build jest command for different modes
local function build_js_test_cmd(mode)
  local file = vim.fn.expand("%")
  if mode == "nearest" then
    local testname = find_nearest_jest_test()
    if testname then
      return string.format("npx jest %s -t '%s'", file, testname)
    else
      return string.format("npx jest %s", file)
    end
  elseif mode == "file" then
    return string.format("npx jest %s", file)
  elseif mode == "suite" then
    return "npx jest"
  end
end

-- Build go test command for different modes
local function build_go_test_cmd(mode)
  if mode == "nearest" or mode == "suite" then
    return "go test -v ./..."
  elseif mode == "file" then
    return "go test -v " .. vim.fn.expand("%:h")
  end
end

-- Find the nearest UT_TEST_SUITE above the cursor
local function find_nearest_custom_cpp_test_suite()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    -- Match UT_TEST_SUITE(testfile, ...)
    local suite_name = line:match('UT_TEST_SUITE%s*%(%s*([%w_]+)')
    if suite_name then return suite_name end
  end
  return nil
end

-- Find the nearest UT_TEST above the cursor
local function find_nearest_custom_cpp_test()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    -- Match UT_TEST(testfile, testcase)
    local suite_name, test_name = line:match('UT_TEST%s*%(%s*([%w_]+)%s*,%s*([%w_]+)')
    if suite_name and test_name then return suite_name, test_name end
  end
  return nil, nil
end

-- Build custom C++ test command for different modes
local function build_custom_cpp_test_cmd(mode)
  local cwd = vim.fn.getcwd()
  if mode == "nearest" then
    local suite_name, test_name = find_nearest_custom_cpp_test()
    if suite_name and test_name then
      return string.format("cd %s && python tools.py test --filter=\"%s.%s\"", cwd, suite_name, test_name)
    else
      -- If no UT_TEST found, try to find UT_TEST_SUITE and run all tests in that suite
      local suite_name = find_nearest_custom_cpp_test_suite()
      if suite_name then
        return string.format("cd %s && python tools.py test --filter=\"%s.*\"", cwd, suite_name)
      else
        return string.format("cd %s && python tools.py test", cwd)
      end
    end
  elseif mode == "file" then
    local suite_name = find_nearest_custom_cpp_test_suite()
    if suite_name then
      return string.format("cd %s && python tools.py test --filter=\"%s.*\"", cwd, suite_name)
    else
      return string.format("cd %s && python tools.py test", cwd)
    end
  elseif mode == "suite" then
    return string.format("cd %s && python tools.py test", cwd)
  end
end

-- Build test command for the current buffer and mode
local function build_test_command(mode)
  if vim.bo.filetype == "python" then
    return build_python_test_cmd(mode)
  elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
    return build_js_test_cmd(mode)
  elseif vim.bo.filetype == "go" then
    return build_go_test_cmd(mode)
  elseif vim.bo.filetype == "cpp" or vim.bo.filetype == "c" or vim.bo.filetype == "cxx" or vim.bo.filetype == "cc" or vim.bo.filetype == "c++" then
    return build_custom_cpp_test_cmd(mode)
  else
    print("No test command configured for filetype: " .. vim.bo.filetype)
    return nil
  end
end

return {
  "nvim-neotest/neotest",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/nvim-nio", -- required by neotest
    -- Test adapters
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-go",
  },
  keys = {
    { "<space>tn", function()
        local cmd = build_test_command("nearest")
        if cmd then send_to_terminal(cmd) end
      end, desc = "Test nearest" },
    { "<space>tf", function()
        local cmd = build_test_command("file")
        if cmd then send_to_terminal(cmd) end
      end, desc = "Test file" },
    { "<space>ts", function()
        local cmd = build_test_command("suite")
        if cmd then send_to_terminal(cmd) end
      end, desc = "Test suite" },
    { "<space>tl", function() 
        print("Last test command not implemented for terminal mode")
      end, desc = "Test last" },
    { "<space>tv", function() require("neotest").output_panel.toggle() end, desc = "Test output" },
    { "<space>tc", function()
        local last_cmd = require("neotest").state.last_run_command
        if last_cmd then
          vim.fn.setreg("+", last_cmd)
          print("Copied to clipboard: " .. last_cmd)
        else
          print("No test command to copy")
        end
      end, desc = "Copy test command" },
    { "<space>tt", function()
        local last_cmd = require("neotest").state.last_run_command
        if not last_cmd then
          print("No test command to send")
          return
        end
        send_to_terminal(last_cmd)
      end, desc = "Send test command to existing terminal" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
        }),
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-go"),
      },
      output = {
        enabled = false, -- totally disable neotest terminal output
        open_on_run = false,
      },
      output_panel = {
        enabled = true,
        open = "botright 15new",
      },
      quickfix = {
        enabled = false,
        open = false,
      },
      status = {
        enabled = false,
        signs = false,
        virtual_text = false,
      },
      icons = {},
    })
  end,
}
