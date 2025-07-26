-- ============================================================================
-- GitHub Copilot - AI pair programming with Chat support
-- ============================================================================

return {
  -- Official Copilot plugin
  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      -- Custom keymaps for Copilot
      -- Use the default copilot tab mapping with fallback
      vim.g.copilot_no_tab_map = false
      vim.g.copilot_assume_mapped = false
      vim.g.copilot_tab_fallback = "\t"
      
      -- Add shift-tab for unindent in insert mode
      vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })
      
      vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
      
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
      { "github/copilot.vim" }, 
      { "nvim-lua/plenary.nvim" }, 
    },
    config = function()
      require("CopilotChat").setup({
        debug = false, -- Enable debugging
        model = 'gpt-4.1',
        agent = 'copilot', -- Chat agent to use
        chat_autocomplete = true, -- Enable chat autocompletion
        remember_as_sticky = true, 
        window = {
          layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
          width = 0.33, -- fractional width of parent, or absolute width in columns when > 1
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
      })
    end,
    keys = {
      -- Chat commands
      { "<space>cc", ":CopilotChat<CR>", desc = "Open Copilot Chat" },
      { "<space>ce", ":CopilotChatExplain<CR>", desc = "Explain code" },
      { "<space>ct", ":CopilotChatTests<CR>", desc = "Generate tests" },
      { "<space>cf", ":CopilotChatFix<CR>", desc = "Fix code" },
      { "<space>co", ":CopilotChatOptimize<CR>", desc = "Optimize code" },
      { "<space>cd", ":CopilotChatDocs<CR>", desc = "Generate docs" },
      { "<space>cr", ":CopilotChatReview<CR>", desc = "Review code" },
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
      { "<space>ae", ":Copilot enable<CR>", desc = "Enable Copilot" },
      { "<space>ad", ":Copilot disable<CR>", desc = "Disable Copilot" },
      { "<space>as", ":Copilot status<CR>", desc = "Copilot status" },
      { "<space>ap", ":Copilot panel<CR>", desc = "Copilot panel" },
    },
  },
}
