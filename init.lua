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

-- Enhanced cursor positioning with special handling for image files in Markdown/Quarto
local autocmd = vim.api.nvim_create_autocmd

-- For image-supporting filetypes: position cursor at first image
autocmd("BufReadPost", {
  pattern = {"*.md", "*.markdown", "*.qmd", "*.quarto"},
  group = vim.api.nvim_create_augroup("cursor_image_files", { clear = true }),
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local found_image = false
    
    -- Image patterns to look for
    local image_patterns = {
      -- Markdown image syntax
      "!%[.*%]%((.-)%)",        -- ![alt](path)
      "!%[%[(.-)%]%]",          -- ![[path]] (Obsidian syntax)
      "<img.-src=[\"'](.-)[\"']", -- HTML image tag
      -- Common image file extensions (standalone or in text)
      "([^%s]+%.jpe?g)", 
      "([^%s]+%.png)",
      "([^%s]+%.gif)",
      "([^%s]+%.webp)",
      "([^%s]+%.bmp)",
      "([^%s]+%.svg)",
      "([^%s]+%.tiff?)"
    }
    
    for i, line in ipairs(lines) do
      for _, pattern in ipairs(image_patterns) do
        if line:match(pattern) then
          -- Move cursor to this line
          vim.api.nvim_win_set_cursor(0, {i, 0})
          found_image = true
          break
        end
      end
      if found_image then break end
    end
    
    -- If no image found, use standard cursor restoration
    if not found_image then
      local line = vim.fn.line "'\""
      if 
        line > 1 
        and line <= vim.fn.line "$" 
        and vim.bo.filetype ~= "commit"
        and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
      then
        vim.cmd 'normal! g`"'
      end
    end
    
  end,
  desc = "Position cursor at first image in markdown/quarto files or restore previous position",
})

-- For all other filetypes: standard cursor restoration
autocmd("BufReadPost", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("cursor_standard_files", { clear = true }),
  callback = function()
    -- Skip if we're in an image filetype (handled by the other autocmd)
    local ft = vim.bo.filetype
    if ft == "markdown" or ft == "quarto" then
      return
    end
    
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
  desc = "Restore cursor position for non-image files",
})

-- testing
require('leap').create_default_mappings()

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
local RAW_PREFIX = "\\"

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
            elseif line:match("^%s*([`~])%1%1") then -- Handle both ``` and ~~~
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
    
    -- Check if in math environment using luasnip-latex-snippets utils
    local utils = require("luasnip-latex-snippets.util.utils")
    
    -- Get the use_treesitter setting from user config (default to false)
    local use_treesitter =  true
    
    -- Don't capitalize if we're in a math zone
    if utils.is_math(use_treesitter) then
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

-- Silence "Is treesitter enabled?" errors
local original_notify = vim.notify
vim.notify = function(msg, ...)
    if msg == "Error: Is treesitter enabled?" then
        return
    end
    return original_notify(msg, ...)
end

-- set keybinds for both INSERT and VISUAL.
vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

-- qmd date autocmd
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.qmd",
  callback = function()
    -- Get today's date in ISO 8601 format (YYYY-MM-DD)
    local today = os.date("%Y-%m-%d")
    
    -- Get the current file name without extension
    local file_path = vim.api.nvim_buf_get_name(0)
    local file_name = vim.fn.fnamemodify(file_path, ":t:r")
    
    -- Convert kebab-case or snake_case to title case
    local title = file_name:gsub("[%-_]", " "):gsub("(%a)([%w]*)", function(first, rest)
      return first:upper() .. rest:lower()
    end)
    
    -- Define the front matter with the dynamic date and title from filename
    local header = string.format([[
---
title: "%s"
author:
- name: Sol Yates
  orcid: 0009-0004-8754-2108
date: '%s'
categories:
- cat1
---
]], title, today)
    
    -- Get all lines in the buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    -- Check if the file already has front matter (starts with "---")
    if #lines == 0 or lines[1] ~= "---" then
      -- Insert front matter at the top
      vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(header, "\n"))
      print("Inserted YAML front matter.")
    end
  end,
})

vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

function ToggleObsidianFrontmatter()
  -- Get the current client instance
  local obsidian = require("obsidian")
  local client = obsidian.get_client()
  
  if not client then
    vim.notify("No active Obsidian client found", vim.log.levels.ERROR)
    return
  end
  
  -- Get the current configuration
  local current_config = client.opts
  
  -- Toggle the disable_frontmatter option
  current_config.disable_frontmatter = not current_config.disable_frontmatter
  
  -- Re-setup with the modified config
  obsidian.setup(current_config)
  
  -- Notify the user
  local state = current_config.disable_frontmatter and "disabled" or "enabled"
  vim.notify("Obsidian frontmatter management " .. state, vim.log.levels.INFO)
end

-- Add a keybinding
vim.api.nvim_set_keymap('n', '<leader>of', 
  [[<cmd>lua ToggleObsidianFrontmatter()<CR>]], 
  { noremap = true, silent = true, desc = "Toggle Obsidian frontmatter" }
)

-- Set this somewhere in your plugin initialization
require("obsidian.yaml").quote_style = "single"

-- Add this to your init.lua or create a new file in your Neovim config directory

-- Function to handle .docx files
local function handle_docx()
  -- Get the current file path
  local file = vim.fn.expand('%:p')
  
  -- Close the current buffer
  vim.cmd('bdelete')
  
  -- Define your preferred application for opening .docx files
  local open_command = vim.fn.has('mac') == 1 and 'open' or 
                      vim.fn.has('win32') == 1 and 'start' or 'xdg-open'
  
  -- Escape spaces in the filename
  file = file:gsub(' ', '\\ ')
  
  -- Execute the command to open the file with the default application
  vim.fn.system(open_command .. ' ' .. file)
  
  -- Notify the user
  vim.notify('Opening ' .. vim.fn.fnamemodify(file, ':t') .. ' with external application', 
             vim.log.levels.INFO)
end

-- Auto-detect Office files by extension
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = {"*.docx", "*.xlsx", "*.pptx", "*.DOCX", "*.XLSX", "*.PPTX"},
  callback = function()
    handle_docx()
  end,
  desc = "Handle Office files with external application"
})

-- Handle ZIP files that might be Office documents
vim.api.nvim_create_autocmd({"BufReadPost"}, {
  callback = function()
    local filename = vim.fn.expand('%:p')
    local filetype = vim.bo.filetype
    
    -- Check if file is being detected as a zip file
    if filetype == "zip" then
      -- Check if the file has an Office extension
      if filename:match("%.docx$") or filename:match("%.xlsx$") or filename:match("%.pptx$") or
         filename:match("%.DOCX$") or filename:match("%.XLSX$") or filename:match("%.PPTX$") then
        handle_docx()
      end
    end
  end,
  desc = "Handle Office files detected as ZIP files"
})

-- For oil.nvim integration - detect when a user tries to open a docx file
vim.api.nvim_create_autocmd({"BufEnter"}, {
  callback = function()
    -- Check if buffer is oil.nvim buffer
    if vim.bo.filetype == "oil" then
      -- Add a mapping to open Office files with external app when selected in oil
      vim.api.nvim_buf_set_keymap(0, "n", "<CR>", [[<cmd>lua require("oil").select()<CR>]], { noremap = true, silent = true })
    end
  end,
  desc = "Add mapping for oil.nvim to open Office files"
})

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = {"*.docx", "*.xlsx", "*.pptx", "*.DOCX", "*.XLSX", "*.PPTX"},
  callback = function(args)
    local file = args.file
    local open_command = vim.fn.has('mac') == 1 and 'open' or
                         vim.fn.has('win32') == 1 and 'start' or 'xdg-open'
    -- Execute the command to open the file externally
    vim.fn.system(open_command .. ' ' .. vim.fn.shellescape(file))
    vim.notify('Opening ' .. vim.fn.fnamemodify(file, ':t') .. ' with external application', vim.log.levels.INFO)
    -- Prevent the file from being loaded in Neovim
  end,
  desc = "Open Office files externally before loading them",
})
