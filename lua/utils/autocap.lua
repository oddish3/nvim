local M = {}

local RAW_PREFIX = '\\'

-- Flag to track if we need to remove the prefix
local remove_prefix = false

-- Check if the cursor is within inline code
local function is_in_inline_code(line, col)
  local count = 0
  for i = 1, col do
    if line:sub(i, i) == '`' then
      count = count + 1
    end
  end
  return count % 2 == 1 -- Odd number of backticks means we're inside inline code
end

-- Check if the cursor is within a link text
local function is_in_link_text(line, col)
  local in_brackets = false
  local i = 1

  while i <= col do
    if line:sub(i, i) == '[' then
      in_brackets = true
    elseif line:sub(i, i) == ']' then
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

  -- Use luasnip-latex-snippets for code block and math detection
  local latex_snippets = require('luasnip-latex-snippets')
  
  -- Don't capitalize if we're in a code block or math zone
  if latex_snippets.is_in_code_block() or latex_snippets.is_in_math() then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line_num = pos[1]
  local col_num = pos[2]
  local line = vim.api.nvim_get_current_line()
  local char = vim.v.char

  -- Don't capitalize within inline code or link text
  -- This handles cases not caught by treesitter
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
  local trimmed_line = line:sub(1, col_num):match('^%s*(.-)%s*$')

  -- Patterns after which to capitalize
  local patterns = {
    '%.', -- Period
    '%?', -- Question mark
    '!', -- Exclamation mark
    '^#+%s*', -- Heading markers
    '^%s*%-%s*', -- Markdown list
    ':%s*', -- After colons
    '^>%s*', -- After blockquote markers
    '^%d+%.%s*', -- After numbered list markers
  }

  -- Check if previous character matches any pattern
  for _, pattern in ipairs(patterns) do
    if trimmed_line:match(pattern .. '$') then
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
    vim.api.nvim_buf_set_text(0, line_num - 1, col_num - 2, line_num - 1, col_num - 1, { '' })

    -- Reset the flag
    remove_prefix = false
  end
end

-- Register the functions globally
_G.auto_capitalize_md = auto_capitalize_md
_G.remove_prefix_character = remove_prefix_character

-- Initialize auto-capitalize as enabled by default for new buffers
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNew' }, {
  pattern = { '*.md', '*.qmd', '*.markdown' },
  callback = function()
    if vim.b.auto_capitalize_enabled == nil then
      vim.b.auto_capitalize_enabled = true
    end
  end,
})

-- Setup autocommands for Markdown and Quarto filetypes
vim.api.nvim_create_autocmd('InsertCharPre', {
  pattern = { '*.md', '*.qmd', '*.markdown' },
  callback = function()
    _G.auto_capitalize_md()
  end,
})

-- Setup autocommand to remove the prefix after insertion
vim.api.nvim_create_autocmd('TextChangedI', {
  pattern = { '*.md', '*.qmd', '*.markdown' },
  callback = function()
    _G.remove_prefix_character()
  end,
})

-- Add command to toggle auto-capitalization
vim.api.nvim_create_user_command('ToggleAutoCapitalize', function()
  local current = vim.b.auto_capitalize_enabled
  if current == nil then
    current = true
  end
  vim.b.auto_capitalize_enabled = not current
  print('Auto-capitalize ' .. (not current and 'enabled' or 'disabled'))
end, {})

-- Optional: Add keymapping to toggle auto-capitalization
vim.keymap.set('n', '<leader>tc', ':ToggleAutoCapitalize<CR>', { noremap = true, silent = true })


-- Return the module table
return M
