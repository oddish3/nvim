-- NOTE: Throughout this config, some plugins are
-- disabled by default. This is because I don't use
-- them on a daily basis, but I still want to keep
-- them around as examples.
-- You can enable them by changing `enabled = false`
-- to `enabled = true` in the respective plugin spec.
-- Some of these also have the
-- PERF: (performance) comment, which
-- indicates that I found them to slow down the config.
-- (may be outdated with newer versions of the plugins,
-- check for yourself if you're interested in using them)

require 'config.global'
require 'config.lazy'
require 'config.autocommands'
require 'config.redir'

-- Set spell checking to British English
vim.o.spell = true
vim.o.spelllang = 'en_gb'

-- remembers and restores the cursor
local autocmd = vim.api.nvim_create_autocmd
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- testing
-- require('leap').create_default_mappings()
require('utils.anki')

require('telescope').setup {
  extensions = {
    zotero = {
      zotero_db_path = "/Users/user/Zotero/zotero.sqlite",
      better_bibtex_db_path = "/Users/user/Zotero/better-bibtex.sqlite",
      zotero_storage_path = "/Users/user/Zotero/storage",
    }
  }
}

-- vim.opt.conceallevel = 1
-- vim.g.vim_markdown_frontmatter = 1
--
-- Cache state to improve performance
-- Cache state to improve performance
local special_block_state = {
    in_code_block = false,
    in_frontmatter = false,
    last_processed_line = 0,
    buffer_id = nil
}

-- The special character to use as the "raw" prefix
local RAW_PREFIX = "~"

-- Flag to track if we need to remove the prefix
local remove_prefix = false

-- Function to check if the current buffer has changed
local function buffer_changed()
    local current_buf = vim.api.nvim_get_current_buf()
    if special_block_state.buffer_id ~= current_buf then
        special_block_state.buffer_id = current_buf
        special_block_state.in_code_block = false
        special_block_state.in_frontmatter = false
        special_block_state.last_processed_line = 0
        return true
    end
    return false
end

-- Function to update the special block state incrementally
local function update_special_block_state(line_num)
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Reset state if buffer changed or if we're checking a line before last processed
    if buffer_changed() or line_num < special_block_state.last_processed_line then
        special_block_state.in_code_block = false
        special_block_state.in_frontmatter = false
        special_block_state.last_processed_line = 0
    end
    
    -- Only process lines we haven't seen yet
    if line_num > special_block_state.last_processed_line then
        local start_line = special_block_state.last_processed_line
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, line_num, false)
        
        for i, line in ipairs(lines) do
            local actual_line_num = start_line + i
            if line:match("^%-%-%-%s*$") then
                special_block_state.in_frontmatter = not special_block_state.in_frontmatter
            elseif line:match("^[`~]{3,}") then -- Handle both ``` and ~~~
                special_block_state.in_code_block = not special_block_state.in_code_block
            end
        end
        
        special_block_state.last_processed_line = line_num
    end
    
    return special_block_state.in_code_block or special_block_state.in_frontmatter
end

-- Function to check if the cursor is within inline code
local function is_in_inline_code(line, col)
    local count = 0
    for i = 1, col do
        if line:sub(i, i) == "`" then
            count = count + 1
        end
    end
    return count % 2 == 1 -- Odd number of backticks means we're inside inline code
end

-- Function to check if the cursor is within a link text
local function is_in_link_text(line, col)
    local in_brackets = false
    local i = 1
    
    while i <= col do
        if line:sub(i, i) == "[" then
            in_brackets = true
        elseif line:sub(i, i) == "]" then
            in_brackets = false
        end
        i = i + 1
    end
    
    return in_brackets
end

-- Auto-capitalization function
local function auto_capitalize_md()
    -- Check if auto-capitalize is enabled for this buffer
    local enabled = vim.b.auto_capitalize_enabled
    if enabled == false then
        return
    end
    
    local pos = vim.api.nvim_win_get_cursor(0)
    local line_num = pos[1]
    local col_num = pos[2]
    local line = vim.api.nvim_get_current_line()
    local char = vim.v.char
    
    -- Early exit if in code block or front matter
    if update_special_block_state(line_num) then
        return
    end
    
    -- Don't capitalize within inline code or link text
    if is_in_inline_code(line, col_num) or is_in_link_text(line, col_num) then
        return
    end
    
    -- Check if the previous character is the special "disable" marker
    if col_num > 0 and line:sub(col_num, col_num) == RAW_PREFIX then
        -- Set flag to remove the prefix after this event
        remove_prefix = true
        -- Keep the character as is (don't capitalize)
        return
    end
    
    -- Capitalize first character of the line
    if col_num == 0 then
        vim.v.char = char:upper()
        return
    end
    
    -- Get the character before the cursor
    local prev_char = line:sub(col_num, col_num)
    local trimmed_line = line:sub(1, col_num):match("^%s*(.-)%s*$")
    
    -- Patterns after which to capitalize
    local patterns = {
        "%.$",       -- Period
        "%?$",       -- Question mark
        "!$",        -- Exclamation mark
        "^#+%s*$",   -- Heading markers
        "^%s*%-%s*$", -- Markdown list
        ":%s*$",     -- After colons
        "^>%s*$",    -- After blockquote markers
        "^%d+%.%s*$" -- After numbered list markers
    }
    
    -- Check if previous character matches any pattern
    for _, pattern in ipairs(patterns) do
        if trimmed_line:match(pattern) then
            vim.v.char = char:upper()
            return
        end
    end
end

-- Function to remove the prefix character after insertion
local function remove_prefix_character()
    if remove_prefix then
        local pos = vim.api.nvim_win_get_cursor(0)
        local line_num = pos[1]
        local col_num = pos[2]
        
        -- Remove the character before the cursor
        vim.api.nvim_buf_set_text(0, line_num-1, col_num-2, line_num-1, col_num-1, {""})
        
        -- Reset the flag
        remove_prefix = false
    end
end

-- Register the functions globally
_G.auto_capitalize_md = auto_capitalize_md
_G.remove_prefix_character = remove_prefix_character

-- Initialize auto-capitalize as enabled by default for new buffers
vim.api.nvim_create_autocmd({"BufEnter", "BufNew"}, {
    pattern = {"*.md", "*.qmd", "*.markdown"},
    callback = function()
        if vim.b.auto_capitalize_enabled == nil then
            vim.b.auto_capitalize_enabled = true
        end
    end
})

-- Setup autocommands for Markdown and Quarto filetypes
vim.api.nvim_create_autocmd("InsertCharPre", {
    pattern = {"*.md", "*.qmd", "*.markdown"},
    callback = function()
        _G.auto_capitalize_md()
    end
})

-- Setup autocommand to remove the prefix after insertion
vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = {"*.md", "*.qmd", "*.markdown"},
    callback = function()
        _G.remove_prefix_character()
    end
})

-- Add command to toggle auto-capitalization
vim.api.nvim_create_user_command("ToggleAutoCapitalize", function()
    local current = vim.b.auto_capitalize_enabled
    if current == nil then
        current = true
    end
    vim.b.auto_capitalize_enabled = not current
    print("Auto-capitalize " .. (not current and "enabled" or "disabled"))
end, {})

-- Optional: Add keymapping to toggle auto-capitalization
vim.keymap.set('n', '<leader>tc', ':ToggleAutoCapitalize<CR>', { noremap = true, silent = true })
