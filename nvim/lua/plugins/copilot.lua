-- ============================================================================
-- GitHub Copilot - AI pair programming with Chat support
-- ============================================================================

return {
  -- Official Copilot plugin
  {
    "github/copilot.vim",
    lazy = true,
    config = function()
      -- Custom keymaps for Copilot
      -- Use the default copilot tab mapping with fallback
      vim.g.copilot_no_tab_map = false
      vim.g.copilot_assume_mapped = false
      vim.g.copilot_tab_fallback = "\t"
      
      -- Add shift-tab for unindent in insert mode
      vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })
      
      -- Copilot suggestion navigation
      vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
      
      -- Accept suggestions
      vim.keymap.set("i", "<C-y>", "<Plug>(copilot-accept)", { desc = "Accept Copilot suggestion" })
      vim.keymap.set("i", "<M-l>", "<Plug>(copilot-accept-word)", { desc = "Accept Copilot word" })
      vim.keymap.set("i", "<M-j>", "<Plug>(copilot-accept-line)", { desc = "Accept Copilot line" })
      
      -- Disable Copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["*"] = false,
        ["javascript"] = true,
        ["typescript"] = true,
        ["lua"] = true,
        ["rust"] = true,
        ["c"] = true,
        ["cpp"] = true,
        ["go"] = true,
        ["python"] = true,
        ["ruby"] = true,
        ["java"] = true,
        ["c_sharp"] = true,
        ["php"] = true,
        ["shell"] = true,
        ["vim"] = true,
      }
    end,
  },
  
  -- Copilot Chat plugin
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = false,
    dependencies = {
      { "zbirenbaum/copilot.vim" }, 
      { "nvim-lua/plenary.nvim" }, 
    },
    config = function()
      require("CopilotChat").setup({
        debug = false, -- Enable debugging
        model = 'gpt-4.1',
        agent = 'copilot', -- Chat agent to use
        chat_autocomplete = true, -- Enable chat autocompletion
        remember_as_sticky = true,
        temperature = 0.1,
        show_help = true,
        highlight_selection = true,
        highlight_headers = true,
        auto_follow_cursor = true,
        auto_insert_mode = false,
        clear_chat_on_new_prompt = false,
        window = {
          layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
          width = 0.25, -- fractional width of parent, or absolute width in columns when > 1
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
            normal = '<C-l>',
            insert = '<C-l>',
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
      { "<space>cc", ":CopilotChat<CR>", mode = {"n", "v"}, desc = "Open Copilot Chat" },
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
      { "<space>cr", ":CopilotChatReview<CR>", desc = "Review code" },
      { "<space>cR", function()
        -- Get git diff
        local diff = vim.fn.system("git diff --cached")
        if not diff or diff == "" then
          vim.notify("No git diff found", vim.log.levels.WARN)
          return
        end
        local prompt = diff .. "\nPlease review the above git diff, point out any potential issues and explain them.\n"
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
                window = { layout = 'vertical', width = 0.33 }
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

      -- Panel commands (keeping original functionality)
      -- To signin, you need to enable, setup and auth
      { "<space>ae", ":Copilot enable<CR>", desc = "Enable Copilot" },
      { "<space>au", ":Copilot setup<CR>", desc = "Copilot setup" },
      { "<space>aa", ":Copilot auth<CR>", desc = "Copilot auth" },
      { "<space>ao", ":Copilot signout<CR>", desc = "Copilot sign out" },
      { "<space>ap", ":Copilot panel<CR>", desc = "Copilot panel" },
      { "<space>ad", ":Copilot disable<CR>", desc = "Disable Copilot" },
      { "<space>as", ":Copilot status<CR>", desc = "Copilot status" },
    },
  },
}
