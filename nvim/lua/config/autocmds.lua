-- ============================================================================
-- Autocmds Configuration
-- ============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- File type specific indentation
augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
    group = "FileTypeIndent",
    pattern = { "javascript", "typescript", "yaml", "yml", "json" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- Java file type detection
autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.java", "*.jav", "*.aidl" },
    callback = function()
        vim.bo.filetype = "java"
    end,
})

-- Highlight current line and column on window focus
augroup("CursorHighlight", { clear = true })
autocmd("WinLeave", {
    group = "CursorHighlight",
    callback = function()
        vim.opt.cursorline = false
        vim.opt.cursorcolumn = false
    end,
})
autocmd("WinEnter", {
    group = "CursorHighlight", 
    callback = function()
        vim.opt.cursorline = true
        vim.opt.cursorcolumn = true
    end,
})

-- Quickfix window positioning
augroup("QuickFixPosition", { clear = true })
autocmd("FileType", {
    group = "QuickFixPosition",
    pattern = "qf",
    callback = function()
        vim.cmd("wincmd J")
        -- Close quickfix with 'q' and return cursor to editor
        vim.keymap.set("n", "q", ":cclose<CR>:wincmd p<CR>", { buffer = true, silent = true })
    end,
})

-- Close preview window when completion is done
autocmd("CompleteDone", {
    callback = function()
        if vim.fn.pumvisible() == 0 then
            vim.cmd("pclose")
        end
    end,
})

-- Remember last position in file
autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lnum = mark[1]
        local last_line = vim.api.nvim_buf_line_count(0)
        if lnum > 0 and lnum <= last_line then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

-- Trim whitespace on save
autocmd("BufWritePre", {
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- C/C++ Header/Source file switching (:A command)
augroup("CppHeaderSwitch", { clear = true })

-- Create :A command for switching between header and source files
vim.api.nvim_create_user_command('A', function()
    local current_file = vim.fn.expand('%:p')
    local file_ext = vim.fn.expand('%:e')
    local file_base = vim.fn.expand('%:p:r')
    
    local alternate_file = nil
    
    if file_ext == 'h' or file_ext == 'hpp' or file_ext == 'hxx' then
        -- Header file, look for source
        local source_extensions = {'cpp', 'cc', 'cxx', 'c'}
        for _, ext in ipairs(source_extensions) do
            local candidate = file_base .. '.' .. ext
            if vim.fn.filereadable(candidate) == 1 then
                alternate_file = candidate
                break
            end
        end
    elseif file_ext == 'cpp' or file_ext == 'cc' or file_ext == 'cxx' or file_ext == 'c' then
        -- Source file, look for header
        local header_extensions = {'h', 'hpp', 'hxx'}
        for _, ext in ipairs(header_extensions) do
            local candidate = file_base .. '.' .. ext
            if vim.fn.filereadable(candidate) == 1 then
                alternate_file = candidate
                break
            end
        end
    end
    
    if alternate_file then
        vim.cmd('edit ' .. alternate_file)
    else
        print('Alternate file not found')
    end
end, { desc = 'Switch between header and source file' })

-- Key mapping for :A command in C/C++ files
autocmd("FileType", {
    group = "CppHeaderSwitch",
    pattern = { "c", "cpp", "cc", "cxx" },
    callback = function()
        vim.keymap.set("n", "<Leader>a", ":A<CR>", { buffer = true, desc = "Alternate file" })
    end,
})
