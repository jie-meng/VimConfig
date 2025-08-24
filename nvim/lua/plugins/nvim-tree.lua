-- ============================================================================
-- File Explorer (nvim-tree) - replaces NERDTree
-- ============================================================================

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  keys = {
    { "<space>w", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
    { "<space>j", ":NvimTreeFindFile<CR>", desc = "Find current file in tree" },
  },
  config = function()
    -- File type handlers for different file types
    local file_handlers = {
      audio = {
        extensions = { "mp3", "wav", "pcm", "ogg", "flac", "aac", "m4a", "wma" },
        handler = function(file_path)
          -- Play audio file using playsound command
          local cmd = string.format("playsound '%s'", file_path)
          vim.fn.jobstart(cmd, {
            detach = true,
            on_exit = function(_, exit_code)
              if exit_code ~= 0 then
                vim.notify("Failed to play audio file: " .. file_path, vim.log.levels.WARN)
              else
                vim.notify("Playing: " .. vim.fn.fnamemodify(file_path, ":t"), vim.log.levels.INFO)
              end
            end
          })
        end
      },
      media = {
        extensions = { 
          -- Images
          "jpg", "jpeg", "png", "gif", "bmp", "webp", "svg", "tiff", "tif", "ico",
          -- Videos
          "mp4", "avi", "mkv", "mov", "wmv", "flv", "webm", "m4v", "3gp", "ogv"
        },
        handler = function(file_path)
          -- Open media files with system default application (same as 's' key)
          local filename = vim.fn.fnamemodify(file_path, ":t")
          local cmd
          
          if vim.fn.has("mac") == 1 then
            cmd = string.format("open '%s'", file_path)
          elseif vim.fn.has("unix") == 1 then
            cmd = string.format("xdg-open '%s'", file_path)
          elseif vim.fn.has("win32") == 1 then
            cmd = string.format("start '' '%s'", file_path)
          else
            vim.notify("Unsupported system for opening media files", vim.log.levels.WARN)
            return
          end
          
          vim.fn.jobstart(cmd, {
            detach = true,
            on_exit = function(_, exit_code)
              if exit_code == 0 then
                vim.notify("Opening: " .. filename, vim.log.levels.INFO)
              else
                vim.notify("Failed to open: " .. filename, vim.log.levels.WARN)
              end
            end
          })
        end
      },
    }

    -- Function to get file extension
    local function get_file_extension(file_path)
      return string.lower(file_path:match("^.+%.(.+)$") or "")
    end

    -- Function to handle file opening based on type
    local function handle_file_open(file_path)
      local extension = get_file_extension(file_path)
      
      -- Check each file type handler
      for file_type, config in pairs(file_handlers) do
        for _, ext in ipairs(config.extensions) do
          if extension == ext then
            config.handler(file_path)
            return true -- File was handled by custom handler
          end
        end
      end
      
      return false -- File should be opened normally
    end
    -- Disable netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      hijack_cursor = false, -- Don't move cursor to tree when opening
      view = {
        width = 40,
        side = "left",
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        
        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)
        
        -- Custom file opening handler
        local function custom_edit()
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          
          if node.type == "file" then
            local file_path = node.absolute_path
            -- Try custom handler first
            if not handle_file_open(file_path) then
              -- Fall back to default behavior
              api.node.open.edit()
            end
          else
            -- For directories, use default behavior
            api.node.open.edit()
          end
        end
        
        -- Override the default <CR> and 'o' mappings
        vim.keymap.set('n', '<CR>', custom_edit, { buffer = bufnr, noremap = true, silent = true, nowait = true })
        vim.keymap.set('n', 'o', custom_edit, { buffer = bufnr, noremap = true, silent = true, nowait = true })
        
        -- Add custom keymaps from global config
        vim.keymap.set('n', 'mx', ':qa!<CR>', { buffer = bufnr, noremap = true, silent = true, desc = "Quit all" })
        vim.keymap.set('n', 'mq', ':q<CR>', { buffer = bufnr, noremap = true, silent = true, desc = "Quit" })

        -- Show file/folder info
        local function show_node_info()
          local api = require("nvim-tree.api")
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          local path = node.absolute_path
          local stat = vim.loop.fs_stat(path)
          if not stat then
            vim.notify("Cannot stat: " .. path, vim.log.levels.WARN)
            return
          end
          if node.type == "file" then
            local size = stat.size or 0
            local ext = path:match("%.([^.]+)$") or "(none)"
            local info = string.format(
              "File: %s\nType: %s\nSize: %.1f KB\nModified: %s",
              vim.fn.fnamemodify(path, ":t"),
              ext,
              size / 1024,
              os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
            )
            vim.notify(info, vim.log.levels.INFO, { title = "File Info" })
          elseif node.type == "directory" then
            -- Count files and total size
            local handle = io.popen(string.format('find "%s" -type f | wc -l', path))
            local file_count = handle and tonumber(handle:read("*l")) or 0
            if handle then handle:close() end
            local size_handle = io.popen(string.format('du -sh "%s" 2>/dev/null | cut -f1', path))
            local total_size = size_handle and size_handle:read("*l") or "?"
            if size_handle then size_handle:close() end
            local info = string.format(
              "Folder: %s\nFiles: %d\nSize: %s\nModified: %s",
              vim.fn.fnamemodify(path, ":t"),
              file_count,
              total_size,
              os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
            )
            vim.notify(info, vim.log.levels.INFO, { title = "Folder Info" })
          end
        end
        vim.keymap.set('n', 'fi', show_node_info, { buffer = bufnr, noremap = true, silent = true, desc = "Show file/folder info" })
      end,
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "",
            modified = "●",
            folder = {
              arrow_closed = "▶",
              arrow_open = "▼",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { "*.pyc", "*.o", "*.obj", "*.exe", "*.class", ".DS_Store", "*.meta" },
      },
      actions = {
        change_dir = {
          enable = true,
          global = true,
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,  -- Don't change working directory when focusing files
      },
      git = {
        enable = true,
        ignore = false,
      },
    })

    -- Auto open nvim-tree when starting nvim
    local function open_nvim_tree(data)
      -- buffer is a directory
      local directory = vim.fn.isdirectory(data.file) == 1

      if not directory then
        return
      end

      -- change to the directory
      vim.cmd.cd(data.file)

      -- open the tree
      require("nvim-tree.api").tree.open()
      
      -- Move focus back to the main window
      vim.cmd("wincmd p")
    end

    vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

    -- Auto open when no files specified
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if vim.fn.argc() == 0 and not vim.g.in_pager_mode then
          require("nvim-tree.api").tree.open()
          -- Move focus back to the main window after opening tree
          vim.schedule(function()
            vim.cmd("wincmd p")
          end)
        end
      end
    }) 

    -- Close nvim-tree if it's the last window
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.fn.winnr('$') == 1 and vim.bo.filetype == "NvimTree" then
          vim.cmd("close")
        end
      end
    })
  end,
}
