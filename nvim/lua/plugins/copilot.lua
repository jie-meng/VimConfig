-- ============================================================================
-- GitHub Copilot - AI pair programming with Chat support
-- ============================================================================

-- Define constants for Copilot Chat window layout and width
local COPILOT_CHAT_WINDOW_LAYOUT = 'vertical'
local COPILOT_CHAT_WINDOW_WIDTH = 0.33

return {
  -- GitHub Copilot for code completion
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<Tab>",
            accept_word = false,
            accept_line = false,
            next = "<C-.>",
            prev = "<C-,>",
            dismiss = "<C-/>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })
      
      -- Set up custom highlight for Copilot suggestions
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
        fg = "#808080", -- Gray color for suggestions
        italic = true 
      })
    end,
      keys = {
        { "<space>Ce", ":Copilot enable<CR>", desc = "Enable Copilot" },
        { "<space>Cu", ":Copilot setup<CR>", desc = "Copilot setup" },
        { "<space>Ca", ":Copilot auth<CR>", desc = "Copilot auth" },
        { "<space>Co", ":Copilot signout<CR>", desc = "Copilot sign out" },
        { "<space>Cp", ":Copilot panel<CR>", desc = "Copilot panel" },
        { "<space>Cd", ":Copilot disable<CR>", desc = "Disable Copilot" },
        { "<space>Cs", ":Copilot status<CR>", desc = "Copilot status" },
      },
  },
  
  -- Copilot Chat plugin with built-in copilot functionality
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main", 
    lazy = false,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- Use copilot.lua for completion
      { "nvim-lua/plenary.nvim", branch = "master" }, -- Required dependency
    },
    build = "make tiktoken", -- Optional: for better token counting
    config = function()
      require("CopilotChat").setup({
        debug = false, -- Enable debugging
        model = 'gpt-4.1',
        temperature = 0.1,
        window = {
          layout = COPILOT_CHAT_WINDOW_LAYOUT, -- Use constant for layout
          width = COPILOT_CHAT_WINDOW_WIDTH, -- Use constant for width
          height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
          -- Options below only apply to floating windows
          relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
          border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
          row = nil, -- row position of the window, default is centered
          col = nil, -- column position of the window, default is centered
          title = 'Copilot Chat', -- title of chat window
          footer = nil, -- footer of chat window
          zindex = 1, -- determines if window is on top or below other floating windows
        },
        mappings = {
          complete = {
            insert = '<Tab>',
          },
          close = {
            normal = 'q',
            insert = '<C-c>',
          },
          reset = {
            normal = 'rs',
            insert = 'rs',
          },
          submit_prompt = {
            normal = '<CR>',
            insert = '<C-s>',
          },
          accept_diff = {
            normal = '<C-y>',
            insert = '<C-y>',
          },
          jump_to_diff = {
            normal = 'gj',
          },
          show_diff = {
            normal = 'gd',
          },
          yank_diff = {
            normal = 'gy',
          },
          show_info = {
            normal = 'gi',
          },
          show_context = {
            normal = 'gc',
          },
          show_help = {
            normal = 'gh',
          },
        },
      })
    end,
    keys = {
      -- Chat commands
      { "<space>cc", function()
        local chat_bufnr = vim.fn.bufnr("copilot-chat")
        if chat_bufnr ~= -1 then
          -- If buffer exists, try to close its window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == chat_bufnr then
              vim.api.nvim_win_close(win, true)
              return
            end
          end
        end
        -- Otherwise, open Copilot Chat
        vim.cmd("CopilotChat")
      end, mode = {"n", "v"}, desc = "Toggle Copilot Chat window" },
      { "<space>ck", function()
        local current_file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        require("CopilotChat").open({ window = { layout = 'vertical', width = 0.33 } })
        vim.defer_fn(function()
          local bufnr = vim.fn.bufnr("copilot-chat")
          if bufnr ~= -1 and current_file ~= "" then
            local file_ref = "#file:" .. current_file .. " "
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, {file_ref})
            vim.api.nvim_win_set_cursor(0, {line_count + 1, #file_ref})
          end
        end, 100)
      end, desc = "Open Copilot Chat (with current file)" },
      { "<space>ce", ":CopilotChatExplain<CR>", mode = {"v"}, desc = "Explain code" },
      { "<space>ct", ":CopilotChatTests<CR>", mode = {"v"}, desc = "Generate tests" },
      { "<space>cf", ":CopilotChatFix<CR>", mode = {"v"}, desc = "Fix code" },
      { "<space>co", ":CopilotChatOptimize<CR>", mode = {"v"}, desc = "Optimize code" },
      { "<space>cd", ":CopilotChatDocs<CR>", mode = {"v"}, desc = "Generate docs" },
      { "<space>cx", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = cursor[1] - 1
        local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
        if #diagnostics == 0 then
          vim.notify("No diagnostic found at cursor line", vim.log.levels.WARN)
          return
        end
        -- Get context (5 lines before and after)
        local start_line = math.max(0, line - 5)
        local end_line = math.min(vim.api.nvim_buf_line_count(bufnr) - 1, line + 5)
        local context_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
        local context_text = table.concat(context_lines, "\n")
        local diag_msgs = {}
        for _, diag in ipairs(diagnostics) do
          table.insert(diag_msgs, diag.message)
        end
        local all_diags = table.concat(diag_msgs, "\n")
        local prompt = "Please analyze the following code snippet and diagnostics, and provide suggestions to fix the issue(s):\n" .. context_text .. "\n\nDiagnostics:\n" .. all_diags
        require("CopilotChat").open({ window = { layout = COPILOT_CHAT_WINDOW_LAYOUT, width = COPILOT_CHAT_WINDOW_WIDTH } })
        vim.defer_fn(function()
          local chat_bufnr = vim.fn.bufnr("copilot-chat")
          if chat_bufnr ~= -1 then
            local line_count = vim.api.nvim_buf_line_count(chat_bufnr)
            local prompt_lines = {}
            for s in prompt:gmatch("([^\n]*)\n?") do
              table.insert(prompt_lines, s)
            end
            if #prompt_lines > 0 and prompt_lines[#prompt_lines] == "" then
              table.remove(prompt_lines, #prompt_lines)
            end
            vim.api.nvim_buf_set_lines(chat_bufnr, line_count, line_count, false, prompt_lines)
            vim.api.nvim_win_set_cursor(0, {line_count + #prompt_lines, #(prompt_lines[#prompt_lines] or "")})
          end
        end, 100)
      end, desc = "Analyze diagnostics at current line and send to Copilot Chat" },
      { "<space>cr", ":CopilotChatReview<CR>", desc = "Review code" },
      { "<space>cR", function()
        -- Get git diff
        local diff = vim.fn.system("git diff --cached")
        if not diff or diff == "" then
          vim.notify("No git diff found", vim.log.levels.WARN)
          return
        end
        local prompt = diff .. "\nPlease review the above git diff, point out any potential issues and explain them, Also generate a commit message.\n"
        require("CopilotChat").open({ window = { layout = 'vertical', width = 0.33 } })
        vim.defer_fn(function()
          local bufnr = vim.fn.bufnr("copilot-chat")
          if bufnr ~= -1 then
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            local lines = {}
            for s in prompt:gmatch("([^\n]*)\n?") do
              table.insert(lines, s)
            end
            if #lines > 0 and lines[#lines] == "" then table.remove(lines, #lines) end
            vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
            vim.api.nvim_win_set_cursor(0, {line_count + #lines, #(lines[#lines] or "")})
          end
        end, 100)
      end, desc = "Review current git diff with Copilot" },
      { "<space>cs", ":CopilotChatCommit<CR>", desc = "Generate commit message" },
      
      -- File picker for chat - select files with Telescope
      { "<space>cF", function()
        require("telescope.builtin").find_files({
          prompt_title = "Select Files for Copilot Chat",
          case_mode = "ignore_case",  -- Ignore case when searching
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            
            -- Custom action to select multiple files
            local function select_files_for_chat()
              local picker = action_state.get_current_picker(prompt_bufnr)
              local selections = picker:get_multi_selection()
              
              -- If no multi-selection, use current selection
              if vim.tbl_isempty(selections) then
                selections = { action_state.get_selected_entry() }
              end
              
              actions.close(prompt_bufnr)
              
              -- Build file list
              local files = {}
              for _, selection in ipairs(selections) do
                table.insert(files, selection.value or selection.path or selection[1])
              end
              
              -- Open CopilotChat with files
              require("CopilotChat").open({
                window = { layout = COPILOT_CHAT_WINDOW_LAYOUT, width = COPILOT_CHAT_WINDOW_WIDTH }
              })
              
              vim.defer_fn(function()
                local bufnr = vim.fn.bufnr("copilot-chat")
                if bufnr ~= -1 then
                  local file_refs
                  if #files == 1 then
                    file_refs = "#file:" .. files[1] .. " "
                  else
                    file_refs = "#files:" .. table.concat(files, ",") .. " "
                  end
                  
                  -- Get the last line number and append to the end
                  local line_count = vim.api.nvim_buf_line_count(bufnr)
                  local lines = {file_refs}
                  vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines)
                  
                  -- Move cursor to the end of the new line
                  vim.api.nvim_win_set_cursor(0, {line_count + 1, #lines[1]})
                  vim.cmd("startinsert!")
                end
              end, 100)
            end
            
            map("i", "<CR>", select_files_for_chat)
            map("n", "<CR>", select_files_for_chat)
            map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            map("n", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
            
            return true
          end,
        })
      end, desc = "Select files for Copilot Chat" },
      
      -- Model management
      { "<space>cm", ":CopilotChatModels<CR>", desc = "Switch Copilot Chat model" },
      { "<space>cM", function()
        local chat = require("CopilotChat")
        local config = chat.config or {}
        local current_model = config.model or "unknown"
        print("Current Copilot Chat model: " .. current_model)
      end, desc = "Show current Copilot Chat model" },
    },
  },
}
