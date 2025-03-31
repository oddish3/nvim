local function set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = { '*' },
  command = 'checktime',
})

vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = { '*' },
  callback = function(_)
    vim.cmd.setlocal 'nonumber'
    vim.wo.signcolumn = 'no'
    set_terminal_keymaps()
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Enhanced cursor positioning with special handling for image files in Markdown/Quarto
local autocmd = vim.api.nvim_create_autocmd

-- For image-supporting filetypes: position cursor at first image
autocmd('BufReadPost', {
  pattern = { '*.md', '*.markdown', '*.qmd', '*.quarto' },
  group = vim.api.nvim_create_augroup('cursor_image_files', { clear = true }),
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local found_image = false

    -- Image patterns to look for
    local image_patterns = {
      -- Markdown image syntax
      '!%[.*%]%((.-)%)', -- ![alt](path)
      '!%[%[(.-)%]%]', -- ![[path]] (Obsidian syntax)
      '<img.-src=["\'](.-)["\']', -- HTML image tag
      -- Common image file extensions (standalone or in text)
      '([^%s]+%.jpe?g)',
      '([^%s]+%.png)',
      '([^%s]+%.gif)',
      '([^%s]+%.webp)',
      '([^%s]+%.bmp)',
      '([^%s]+%.svg)',
      '([^%s]+%.tiff?)',
    }

    for i, line in ipairs(lines) do
      for _, pattern in ipairs(image_patterns) do
        if line:match(pattern) then
          -- Move cursor to this line
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          found_image = true
          break
        end
      end
      if found_image then
        break
      end
    end

    -- If no image found, use standard cursor restoration
    if not found_image then
      local line = vim.fn.line '\'"'
      if line > 1 and line <= vim.fn.line '$' and vim.bo.filetype ~= 'commit' and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1 then
        vim.cmd 'normal! g`"'
      end
    end
  end,
  desc = 'Position cursor at first image in markdown/quarto files or restore previous position',
})

-- For all other filetypes: standard cursor restoration
autocmd('BufReadPost', {
  pattern = '*',
  group = vim.api.nvim_create_augroup('cursor_standard_files', { clear = true }),
  callback = function()
    -- Skip if we're in an image filetype (handled by the other autocmd)
    local ft = vim.bo.filetype
    if ft == 'markdown' or ft == 'quarto' then
      return
    end

    local line = vim.fn.line '\'"'
    if line > 1 and line <= vim.fn.line '$' and vim.bo.filetype ~= 'commit' and vim.fn.index({ 'xxd', 'gitrebase' }, vim.bo.filetype) == -1 then
      vim.cmd 'normal! g`"'
    end
  end,
  desc = 'Restore cursor position for non-image files',
})

-- qmd date autocmd
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.qmd',
  callback = function()
    -- Get today's date in ISO 8601 format (YYYY-MM-DD)
    local today = os.date '%Y-%m-%d'

    -- Get the current file name without extension
    local file_path = vim.api.nvim_buf_get_name(0)
    local file_name = vim.fn.fnamemodify(file_path, ':t:r')

    -- Convert kebab-case or snake_case to title case
    local title = file_name:gsub('[%-_]', ' '):gsub('(%a)([%w]*)', function(first, rest)
      return first:upper() .. rest:lower()
    end)

    -- Define the front matter with the dynamic date and title from filename
    local header = string.format(
      [[
---
title: "%s"
author:
- name: Sol Yates
  orcid: 0009-0004-8754-2108
date: '%s'
categories:
- cat1
---
]],
      title,
      today
    )

    -- Get all lines in the buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Check if the file already has front matter (starts with "---")
    if #lines == 0 or lines[1] ~= '---' then
      -- Insert front matter at the top
      vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(header, '\n'))
      -- print("Inserted YAML front matter.")
    end
  end,
})

local function handle_docx()
  -- Get the current file path
  local file = vim.fn.expand '%:p'

  -- Close the current buffer
  vim.cmd 'bdelete'

  -- Define your preferred application for opening .docx files
  local open_command = vim.fn.has 'mac' == 1 and 'open' or vim.fn.has 'win32' == 1 and 'start' or 'xdg-open'

  -- Escape spaces in the filename
  file = file:gsub(' ', '\\ ')

  -- Execute the command to open the file with the default application
  vim.fn.system(open_command .. ' ' .. file)

  -- Notify the user
  vim.notify('Opening ' .. vim.fn.fnamemodify(file, ':t') .. ' with external application', vim.log.levels.INFO)
end

-- Auto-detect Office files by extension
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern = { '*.docx', '*.xlsx', '*.pptx', '*.DOCX', '*.XLSX', '*.PPTX' },
  callback = function()
    handle_docx()
  end,
  desc = 'Handle Office files with external application',
})

-- Handle ZIP files that might be Office documents
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  callback = function()
    local filename = vim.fn.expand '%:p'
    local filetype = vim.bo.filetype

    -- Check if file is being detected as a zip file
    if filetype == 'zip' then
      -- Check if the file has an Office extension
      if
        filename:match '%.docx$'
        or filename:match '%.xlsx$'
        or filename:match '%.pptx$'
        or filename:match '%.DOCX$'
        or filename:match '%.XLSX$'
        or filename:match '%.PPTX$'
      then
        handle_docx()
      end
    end
  end,
  desc = 'Handle Office files detected as ZIP files',
})

-- For oil.nvim integration - detect when a user tries to open a docx file
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  callback = function()
    -- Check if buffer is oil.nvim buffer
    if vim.bo.filetype == 'oil' then
      -- Add a mapping to open Office files with external app when selected in oil
      vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', [[<cmd>lua require("oil").select()<CR>]], { noremap = true, silent = true })
    end
  end,
  desc = 'Add mapping for oil.nvim to open Office files',
})

vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = { '*.docx', '*.xlsx', '*.pptx', '*.DOCX', '*.XLSX', '*.PPTX' },
  callback = function(args)
    local file = args.file
    local open_command = vim.fn.has 'mac' == 1 and 'open' or vim.fn.has 'win32' == 1 and 'start' or 'xdg-open'
    -- Execute the command to open the file externally
    vim.fn.system(open_command .. ' ' .. vim.fn.shellescape(file))
    vim.notify('Opening ' .. vim.fn.fnamemodify(file, ':t') .. ' with external application', vim.log.levels.INFO)
    -- Prevent the file from being loaded in Neovim
  end,
  desc = 'Open Office files externally before loading them',
})
