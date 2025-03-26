local M = {}

function process_text(text)
  -- Keep track of our position in the string and build result
  local result = ''
  local pos = 1
  local in_math = false
  local math_start_pos = nil
  local is_display_math = false

  while pos <= #text do
    -- Check for math delimiters
    if text:sub(pos, pos + 1) == '$$' then
      -- Handle display math ($$)
      if not in_math then
        -- Opening display math
        result = result .. '[$$]'
        in_math = true
        is_display_math = true
        math_start_pos = pos
        pos = pos + 2
      elseif is_display_math then
        -- Closing display math that was opened with $$
        result = result .. '[/$$]'
        in_math = false
        is_display_math = false
        pos = pos + 2
      else
        -- We're in inline math but found $$, treat as text
        result = result .. '$$'
        pos = pos + 2
      end
    elseif text:sub(pos, pos) == '$' and not (pos > 1 and text:sub(pos - 1, pos) == '\\$') then
      -- Handle inline math ($), but not escaped \$
      if not in_math then
        -- Opening inline math
        result = result .. '[$]'
        in_math = true
        is_display_math = false
        math_start_pos = pos
        pos = pos + 1
      elseif not is_display_math then
        -- Closing inline math that was opened with $
        result = result .. '[/$]'
        in_math = false
        pos = pos + 1
      else
        -- We're in display math but found $, treat as text
        result = result .. '$'
        pos = pos + 1
      end
    else
      -- Handle regular characters
      local current_char = text:sub(pos, pos)

      -- Escape backslashes outside of math
      if current_char == '\\' and not in_math then
        result = result .. '\\\\'
      else
        result = result .. current_char
      end

      pos = pos + 1
    end
  end

  -- Check if we have unclosed math delimiters
  if in_math then
    vim.notify('Warning: Unclosed math delimiter found', vim.log.levels.WARN)
  end

  return result
end


-- This function processes the current buffer's block of text and creates notes
function M.create_notes()
  local bufnr = vim.api.nvim_get_current_buf()
  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local total_lines = #all_lines
  if total_lines == 0 then return end

  -- Determine the block boundaries based on the current line.
  local current_line = vim.fn.line('.')  -- 1-indexed
  local start_idx, end_idx = current_line, current_line

  -- Go upward until an empty line or beginning of file
  for i = current_line, 1, -1 do
    if all_lines[i]:match("^%s*$") then
      start_idx = i + 1
      break
    elseif i == 1 then
      start_idx = 1
    end
  end

  -- Go downward until an empty line or end of file
  for i = current_line, total_lines do
    if all_lines[i]:match("^%s*$") then
      end_idx = i - 1
      break
    elseif i == total_lines then
      end_idx = total_lines
    end
  end

  -- Get the block of lines that defines our note(s)
  local block_lines = {}
  for i = start_idx, end_idx do
    table.insert(block_lines, all_lines[i])
  end

  if #block_lines == 0 then return end

  -- Parse the first line for model/deck/tags info.
  -- Format should be: model/deck/tags
  local category_line = table.remove(block_lines, 1)
  local model, deck, tags = "Basic", "Default", ""
  local parts = {}
  for part in string.gmatch(category_line, "[^/]+") do
    table.insert(parts, vim.trim(part))
  end
  if #parts >= 1 and parts[1] ~= "" then
    model = parts[1]
  end
  if #parts >= 2 and parts[2] ~= "" then
    deck = parts[2]
  end
  if #parts >= 3 and parts[3] ~= "" then
    tags = parts[3]
  end

  -- Parse the rest of the block for Q/A entries.
  -- Optionally, allow a line starting with "tags:" to override tags.
  local notes = {}
  local current_note = { q = {}, a = {}, tags = tags }
  local mode = nil -- "q" for question, "a" for answer
  for _, line in ipairs(block_lines) do
    if vim.startswith(line, "tags:") then
      local new_tags = line:match("^tags:%s*(.*)")
      if new_tags and new_tags ~= "" then
        current_note.tags = new_tags
      end
    elseif vim.startswith(line, "Q:") then
      -- If there is an existing note, store it and start a new one.
      if (#current_note.q > 0 or #current_note.a > 0) then
        table.insert(notes, current_note)
        current_note = { q = {}, a = {}, tags = tags }
      end
      mode = "q"
      local qline = line:sub(4) -- drop "Q:" and following space
      table.insert(current_note.q, vim.trim(qline))
    elseif vim.startswith(line, "A:") then
      mode = "a"
      local aline = line:sub(4) -- drop "A:" and following space
      table.insert(current_note.a, vim.trim(aline))
    else
      if mode == "q" then
        table.insert(current_note.q, line)
      elseif mode == "a" then
        table.insert(current_note.a, line)
      end
    end
  end
  if (#current_note.q > 0 or #current_note.a > 0) then
    table.insert(notes, current_note)
  end

  -- Define the template for the note.
  local template = [[
# Note
model: %s
deck: %s
tags: %s
markdown: true

## Front
%s

## Back
%s
]]
    local new_notes = {}

  for _, note in ipairs(notes) do
    -- Process question and answer with process_text
    local question = process_text(table.concat(note.q, "\n"))
    local answer = process_text(table.concat(note.a, "\n"))
    local note_str = string.format(template, model, deck, note.tags, question, answer)
    table.insert(new_notes, note_str)
  end

  -- Helper function to split note_str into lines while preserving empty lines
  local function split_lines(str)
    local lines = {}
    if #str == 0 then return lines end
    local pos = 1
    while pos <= #str do
      local nl_pos = str:find('\n', pos)
      if not nl_pos then
        table.insert(lines, str:sub(pos))
        break
      end
      table.insert(lines, str:sub(pos, nl_pos - 1))
      pos = nl_pos + 1
    end
    return lines
  end

  -- Prepare new block with correct line splitting
  local new_block = {}
  for _, note_str in ipairs(new_notes) do
    local lines = split_lines(note_str)
    vim.list_extend(new_block, lines)
    table.insert(new_block, "")  -- Add blank line between notes
  end

  -- Replace the original block in the buffer with the new block
  vim.api.nvim_buf_set_lines(bufnr, start_idx - 1, end_idx, false, new_block)
  -- Optionally, move the cursor back to the start of the block
  vim.api.nvim_win_set_cursor(0, {start_idx, 0})
  vim.cmd("update")
end

-- Function to copy clipboard image to Anki media and insert markdown link
function M.paste_image_to_anki()
  -- Path to Anki's media collection
  local anki_media = vim.fn.expand '~/Library/Application Support/Anki2/User 1/collection.media'

  -- Create a temporary directory for processing
  local temp_dir = vim.fn.expand '~/.cache/nvim/clipboard_images'
  vim.fn.mkdir(temp_dir, 'p')

  -- Generate a timestamp for unique filenames
  local timestamp = os.time()
  local temp_file = string.format('%s/clipboard_image_%s.png', temp_dir, timestamp)

  -- Determine which clipboard tool to use
  local clipboard_cmd
  if vim.fn.executable 'img-clip' == 1 then
    clipboard_cmd = string.format('img-clip save %s', vim.fn.shellescape(temp_file))
  elseif vim.fn.executable 'pngpaste' == 1 then
    clipboard_cmd = string.format('pngpaste %s', vim.fn.shellescape(temp_file))
  else
    vim.notify('No clipboard image tool found. Please install img-clip or pngpaste.', vim.log.levels.ERROR)
    return
  end

  -- Try to save clipboard content to the temporary file
  local result = os.execute(clipboard_cmd)

  -- Check if the command succeeded and the file exists with content
  if result ~= 0 or vim.fn.filereadable(temp_file) ~= 1 or vim.fn.getfsize(temp_file) <= 0 then
    vim.notify('No image found in clipboard or failed to save it.', vim.log.levels.WARN)
    -- Clean up if file was created but empty
    if vim.fn.filereadable(temp_file) == 1 then
      os.remove(temp_file)
    end
    return
  end

  -- Prompt for image name
  local default_name = 'clipboard_image_' .. timestamp
  local image_name = vim.fn.input('Image name: ', default_name)
  if image_name == '' then
    os.remove(temp_file)
    return
  end
  vim.cmd 'redraw!'

  -- Create final filename and path
  local filename = image_name .. '.png'
  local destination = anki_media .. '/' .. filename

  -- Copy image to Anki media folder
  local copy_cmd = string.format('cp %s %s', vim.fn.shellescape(temp_file), vim.fn.shellescape(destination))
  local copy_success = os.execute(copy_cmd) == 0

  -- Clean up temporary file
  os.remove(temp_file)

  if not copy_success then
    vim.notify('Failed to copy image to Anki media folder.', vim.log.levels.ERROR)
    return
  end

  -- Insert markdown link at cursor position
  local markdown_link = string.format('![%s](%s)', image_name, filename)
  vim.api.nvim_put({ markdown_link }, 'c', true, true)

  vim.notify('Image copied to Anki media and link inserted.', vim.log.levels.INFO)
end

-- Function to run `apy add-from-file` on the current file
function M.run_apy_add_from_file()
  vim.cmd 'write' -- Save the current buffer
  local file_path = vim.fn.expand '%:p' -- Get the full path of the current file
  local command = 'apy add-from-file ' .. vim.fn.shellescape(file_path)
  vim.cmd('!' .. command) -- Execute the command in the shell
end

-- Function to run `apy add-from-file` on the current file
function M.run_apy_update_from_file()
  vim.cmd 'write' -- Save the current buffer
  local file_path = vim.fn.expand '%:p' -- Get the full path of the current file
  local command = 'python3 /Users/user/repos/scripts/apy-update.py -u ' .. vim.fn.shellescape(file_path)
  vim.cmd('!' .. command) -- Execute the command in the shell
end

-- Export functions to the global scope for keymap access
_G.create_notes = M.create_notes
_G.paste_image_to_anki = M.paste_image_to_anki
_G.run_apy_add_from_file = M.run_apy_add_from_file
_G.run_apy_update_from_file = M.run_apy_update_from_file

vim.keymap.set('n', '<leader>ac', '<cmd>lua create_notes()<CR>', { noremap = true, silent = true, desc = '[C]reate Notes' })
vim.keymap.set('n', '<leader>ap', '<cmd>lua paste_image_to_anki()<CR>', { noremap = true, silent = true, desc = '[P]aste image' })
vim.keymap.set('n', '<leader>aa', '<cmd>lua run_apy_add_from_file()<CR>', { noremap = true, silent = true, desc = '[A]dd notes' })
vim.keymap.set('n', '<leader>au', '<cmd>lua run_apy_update_from_file()<CR>', { noremap = true, silent = true, desc = '[U]pdate from note' })

-- Return the module table
return M
