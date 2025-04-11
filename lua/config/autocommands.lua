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

-- Function to open files externally (more robust version)
local function open_externally(file_path)
  -- Determine the OS-specific open command
  local open_command
  -- Use 'macunix' for macOS, as 'mac' can be ambiguous in some contexts
  if vim.fn.has('macunix') then
    open_command = 'open'
  elseif vim.fn.has('win32') then
    -- Using 'start ""' is safer on Windows to handle paths correctly
    open_command = 'start ""'
  else -- Assume Linux/BSD/other Unix-like
    -- Check if xdg-open exists, fallback otherwise if needed
    if vim.fn.executable('xdg-open') == 1 then
      open_command = 'xdg-open'
    else
      vim.notify('Could not find xdg-open. Please install it or configure an alternative.', vim.log.levels.ERROR)
      return -- Stop if no open command is found
    end
  end

  -- Properly escape the file path for shell execution
  local escaped_file_path = vim.fn.shellescape(file_path)

  -- Construct the full command
  local command = open_command .. ' ' .. escaped_file_path

  -- Execute the command asynchronously using jobstart to avoid blocking Neovim
  vim.fn.jobstart(command, {
    detach = true, -- Run the process independently of Neovim
    -- Hide the command window on Windows if 'start' pops one up briefly
    hide = vim.fn.has('win32') == 1,
  })

  -- Notify the user
  vim.notify('Attempting to open ' .. vim.fn.fnamemodify(file_path, ':t') .. ' externally', vim.log.levels.INFO)

  -- *** Crucial Part for BufReadCmd ***
  -- Signal to Neovim that we have handled the command and it should not
  -- proceed with loading the file into a buffer.
  -- Setting vim.v.cmdarg = '' is one way.
  -- Creating a temporary buffer and immediately setting options to discard it works well too.
  vim.cmd('setlocal buflisted nobuflisted') -- Don't list this buffer
  vim.cmd('setlocal bufhidden=wipe')      -- Delete the buffer when hidden (immediately)

  -- Alternative signal (often used):
  -- vim.v.cmdarg = '' -- Clear arguments to prevent default :read action

  -- No need for bdelete, as we prevent the buffer from being properly loaded/kept.
end

-- Create an autocommand group to easily manage our autocommands
local externalOpenGroup = vim.api.nvim_create_augroup('ExternalOpeners', { clear = true })

-- Intercept attempts to read specific file types using BufReadCmd
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = externalOpenGroup,
  pattern = {
    -- Office files (case-insensitive using Lua patterns)
    '*.docx', '*.DOCX',
    '*.xlsx', '*.XLSX',
    '*.pptx', '*.PPTX',
    -- PDF files (case-insensitive)
    '*.pdf', '*.PDF',
  },
  callback = function(args)
    -- args.file contains the full path to the file Neovim is trying to read
    open_externally(args.file)
  end,
  desc = 'Open Office documents and PDFs externally',
})
