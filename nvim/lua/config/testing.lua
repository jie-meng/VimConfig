-- ============================================================================
-- Testing Configuration - Custom test runners for different languages
-- ============================================================================

local terminal_utils = require("config.terminal")

-- Store last test command in memory
local last_test_command = nil

-- Send a command to the terminal and enter insert mode
local function send_to_terminal(command)
  if terminal_utils.send_to_terminal(command) then
    -- Store the command for later use with <space>tl
    last_test_command = command
  end
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

-- Find the nearest UT_TEST_SUITE above the cursor (support multiline, skip commented lines)
local function find_nearest_custom_cpp_test_suite()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  local acc = ""
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    if line:match("^%s*//") then acc = "" goto continue end
    acc = line .. " " .. acc
    local suite_name = acc:match('UT_TEST_SUITE%s*%(%s*([%w_]+)')
    if suite_name then return suite_name end
    ::continue::
  end
  return nil
end

-- Find the nearest UT_TEST above the cursor (support multiline, skip commented lines)
local function find_nearest_custom_cpp_test()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  local acc = ""
  for i = cur_line, 1, -1 do
    local line = vim.fn.getline(i)
    if line:match("^%s*//") then acc = "" goto continue end
    acc = line .. " " .. acc
    local suite_name, test_name = acc:match('UT_TEST%s*%(%s*([%w_]+)%s*,%s*([%w_]+)')
    if suite_name and test_name then return suite_name, test_name end
    ::continue::
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

-- Detect if the project is Gradle or Maven
local function detect_build_tool()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
    return "gradle"
  elseif vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
    return "maven"
  else
    return nil
  end
end

-- Find the nearest Kotlin/Java test class name
local function find_nearest_kotlin_java_test_class()
  -- Only consider as test class if @Test appears in the file
  local has_test = false
  local total_lines = vim.fn.line('$')
  for i = 1, total_lines do
    local line = vim.fn.getline(i)
    if line:match("@Test") then
      has_test = true
      break
    end
  end
  if not has_test then
    return nil
  end
  -- Find package name
  local package_name = nil
  for i = 1, total_lines do
    local line = vim.fn.getline(i)
    local pkg = line:match("^%s*package%s+([%w%.]+)")
    if pkg then
      package_name = pkg
      break
    end
  end
  -- Find the nearest class definition above cursor
  local cursor = vim.api.nvim_win_get_cursor(0)
  for i = cursor[1], 1, -1 do
    local line = vim.fn.getline(i)
    local class_name = line:match("class%s+([%w_]+)")
    if class_name then
      if package_name then
        return package_name .. "." .. class_name
      else
        return class_name
      end
    end
  end
  return nil
end

-- Find the nearest Kotlin/Java test method name (support @Test and method definition on separate lines)
local function find_nearest_kotlin_java_test_method()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local acc = ""
  local test_line = nil
  
  -- First, find the nearest @Test annotation above cursor
  for i = cursor[1], 1, -1 do
    local line = vim.fn.getline(i)
    if line:match("^%s*@Test") then
      test_line = i
      break
    end
  end
  
  if not test_line then
    return nil
  end
  
  -- Then, search downward from @Test to find method name
  local total_lines = vim.fn.line('$')
  for i = test_line, total_lines do
    local line = vim.fn.getline(i)
    
    -- Skip commented lines
    if line:match("^%s*//") then
      acc = ""
      goto continue
    end
    
    -- Skip @Test line itself
    if line:match("^%s*@Test") then
      acc = ""
      goto continue
    end
    
    -- Accumulate lines and look for method name
    acc = acc .. " " .. line
    
    -- Match method name patterns:
    -- 1. Kotlin backtick method: fun `method name`(
    -- 2. Kotlin normal method: fun methodName(
    -- 3. Java method: public/private/protected void/type methodName(
    local method_name = acc:match("fun%s+`([^`]+)`%s*%(") or  -- Kotlin backtick method
                       acc:match("fun%s+([%w_]+)%s*%(") or    -- Kotlin normal method
                       acc:match("void%s+([%w_]+)%s*%(") or   -- Java void method
                       acc:match("public%s+void%s+([%w_]+)%s*%(") or   -- Java public void method
                       acc:match("private%s+void%s+([%w_]+)%s*%(") or  -- Java private void method
                       acc:match("protected%s+void%s+([%w_]+)%s*%(") or -- Java protected void method
                       acc:match("%s+([%w_]+)%s*%(%s*%)%s*{") or  -- Method with () { pattern
                       acc:match("%s+([%w_]+)%s*%(") -- Simple method pattern
    
    if method_name then
      return method_name
    end
    
    ::continue::
  end
  return nil
end

-- Build test command for Kotlin/Java
local function build_kotlin_java_test_cmd(mode)
  local build_tool = detect_build_tool()
  if not build_tool then
    print("No Gradle or Maven build tool detected.")
    return nil
  end

  local class_name = find_nearest_kotlin_java_test_class()
  if not class_name then
    print("No test class found.")
    return nil
  end

  if mode == "nearest" then
    local method_name = find_nearest_kotlin_java_test_method()
    if not method_name then
      print("No test method found.")
      return nil
    end

    if build_tool == "gradle" then
      return string.format("./gradlew test --tests \"%s.%s\"", class_name, method_name)
    elseif build_tool == "maven" then
      return string.format("mvn test -Dtest=%s#%s", class_name, method_name)
    end
  elseif mode == "file" then
    if build_tool == "gradle" then
      return string.format("./gradlew test --tests \"%s\"", class_name)
    elseif build_tool == "maven" then
      return string.format("mvn test -Dtest=%s", class_name)
    end
  elseif mode == "suite" then
    if build_tool == "gradle" then
      return "./gradlew test"
    elseif build_tool == "maven" then
      return "mvn test"
    end
  end
end

-- Extend build_test_command to support Kotlin/Java
local function build_test_command(mode)
  if vim.bo.filetype == "python" then
    return build_python_test_cmd(mode)
  elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
    return build_js_test_cmd(mode)
  elseif vim.bo.filetype == "go" then
    return build_go_test_cmd(mode)
  elseif vim.bo.filetype == "cpp" or vim.bo.filetype == "c" or vim.bo.filetype == "cxx" or vim.bo.filetype == "cc" or vim.bo.filetype == "c++" then
    return build_custom_cpp_test_cmd(mode)
  elseif vim.bo.filetype == "java" or vim.bo.filetype == "kotlin" then
    return build_kotlin_java_test_cmd(mode)
  else
    print("No test command configured for filetype: " .. vim.bo.filetype)
    return nil
  end
end

-- Set up keymaps for testing
vim.keymap.set("n", "<space>tn", function()
  local cmd = build_test_command("nearest")
  if cmd then send_to_terminal(cmd) end
end, { desc = "Test nearest" })

vim.keymap.set("n", "<space>tf", function()
  local cmd = build_test_command("file")
  if cmd then send_to_terminal(cmd) end
end, { desc = "Test file" })

vim.keymap.set("n", "<space>ts", function()
  local cmd = build_test_command("suite")
  if cmd then send_to_terminal(cmd) end
end, { desc = "Test suite" })

vim.keymap.set("n", "<space>tl", function()
  if last_test_command then
    send_to_terminal(last_test_command)
  else
    print("No previous test command found")
  end
end, { desc = "Test last" })