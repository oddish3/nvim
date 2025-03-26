local M = {}

--- Parse default deck and tags from the marker line
--- @param line string The line containing default deck/tags
--- @return table Table containing parsed deck and tags
local function parse_defaults(line)
  -- Default values
  local defaults = {
    deck = 'Default',
    tags = {},
    use_markdown = true,
  }

  if not line or vim.trim(line) == '' then
    return defaults
  end

  -- More robust splitting to handle complex cases
  local parts = {}
  local first_part = line:match('^([^/]+)')
  
  if first_part then
    defaults.deck = vim.trim(first_part)
  end

  -- Extract remaining parts after the first '/'
  local remainder = line:match('^[^/]+/(.+)$')
  
  if remainder then
    -- Split remaining parts and process
    for part in remainder:gmatch('[^/]+') do
      local trimmed_part = vim.trim(part)
      
      -- Check for option settings
      local option_name, option_value = trimmed_part:match '^(%w+):%s*(%w+)$'
      if option_name and option_value then
        if option_name == 'markdown' then
          defaults.use_markdown = option_value == 'true'
        end
      elseif trimmed_part ~= '' then
        table.insert(defaults.tags, trimmed_part)
      end
    end
  end

  return defaults
end

--- Process text with math delimiter conversion
--- @param text string Text to process
--- @return string Processed text
local function process_text(text)
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

--- Parse and extract a Q/A pair from lines
--- @param all_lines table Array of lines
--- @param q_start number Start line of question
--- @param a_start number Start line of answer
--- @param end_index number End line of the Q/A pair
--- @param use_markdown boolean Whether to use markdown formatting
--- @return table Table containing question and answer texts
local function extract_qa_pair(all_lines, q_start, a_start, end_index, use_markdown)
  -- Extract the Q/A pair
  local q_lines = {}
  for i = q_start, a_start - 1 do
    table.insert(q_lines, all_lines[i])
  end

  local a_lines = {}
  for i = a_start, end_index do
    table.insert(a_lines, all_lines[i])
  end

  -- Format the question and answer
  local q_text = q_lines[1]:match '^Q: (.*)' or ''
  if #q_lines > 1 then
    local additional_q_lines = {}
    for i = 2, #q_lines do
      table.insert(additional_q_lines, q_lines[i])
    end
    q_text = q_text .. '\n' .. table.concat(additional_q_lines, '\n')
  end

  local a_text = a_lines[1]:match '^A: (.*)' or ''
  if #a_lines > 1 then
    local additional_a_lines = {}
    for i = 2, #a_lines do
      table.insert(additional_a_lines, a_lines[i])
    end
    a_text = a_text .. '\n' .. table.concat(additional_a_lines, '\n')
  end

  -- Process text with math delimiter conversion if needed
  if use_markdown then
    q_text = process_text(q_text)
    a_text = process_text(a_text)
  end

  return { question = q_text, answer = a_text }
end

--- Format a note using the template
--- @param deck string Deck name
--- @param tags string Tags string
--- @param question string Question text
--- @param answer string Answer text
--- @param use_markdown boolean Whether to use markdown formatting
--- @return string Formatted note
local function format_note(deck, tags, question, answer, use_markdown)
  -- Define the template for each note
  local template = table.concat({
    '# Note',
    'model: Basic',
    'deck: {deck}',
    'tags: {tags}',
    'markdown: {markdown}',
    '',
    '## Front',
    '{q}',
    '',
    '## Back',
    '{a}',
  }, '\n')

  -- Apply the template
  local note =
    template:gsub('{deck}', deck):gsub('{tags}', tags):gsub('{markdown}', tostring(use_markdown)):gsub('{q}', question):gsub('{a}', answer):gsub('  \n', '\n\n') -- Replace double spaces before newlines with blank lines

  return note
end

--- Find all Q/A pairs in a section
--- @param all_lines table Array of lines
--- @param section_start number Start line of the section
--- @param section_end number End line of the section
--- @return table Array of tables with q_start, a_start, and end_index
local function find_all_qa_pairs(all_lines)
  local pairs = {}
  local q_start = nil
  local a_start = nil

  for i = 1, #all_lines do
    local line = all_lines[i]

    if line and line:match '^Q:' then
      if q_start and not a_start then
        vim.notify('Warning: Question at line ' .. q_start .. ' has no answer', vim.log.levels.WARN)
      end
      q_start = i
      a_start = nil
    elseif line and line:match '^A:' and q_start and not a_start then
      a_start = i
      local end_index = #all_lines
      
      for j = a_start + 1, #all_lines do
        if all_lines[j] and all_lines[j]:match '^Q:' then
          end_index = j - 1
          break
        end
      end

      table.insert(pairs, {
        q_start = q_start,
        a_start = a_start,
        end_index = end_index,
      })
    end
  end

  if q_start and not a_start then
    vim.notify('Warning: Question at line ' .. q_start .. ' has no answer', vim.log.levels.WARN)
  end

  return pairs
end

--- Creates notes from all Q/A pairs in the buffer
--- @param options table Optional settings (use_markdown)
--- @return nil
function M.create_notes(options)
  options = options or {}
  local force_markdown = options.markdown

  -- Get all lines from the buffer
  local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Find all Q/A pairs in the entire buffer
  local qa_pairs = find_all_qa_pairs(all_lines)

  if #qa_pairs == 0 then
    vim.notify('No Q/A pairs found in buffer', vim.log.levels.WARN)
    return
  end

  -- Find default settings from first non-QA line at top of file
  local default_settings = parse_defaults('')
  for i = 1, #all_lines do
    local line = all_lines[i]
    if line and not line:match '^[QA]:' then
      default_settings = parse_defaults(line)
      break
    end
  end

  -- Get default settings
  local section_deck = default_settings.deck
  local section_tags = table.concat(default_settings.tags, ' ')
  local section_use_markdown = force_markdown or default_settings.use_markdown

  -- Process each Q/A pair and generate formatted notes
  local all_notes = {}
  local previous_end = 0

  for _, pair in ipairs(qa_pairs) do
    -- Look for override lines between previous pair's end and current pair's start
    local override_settings = nil
    for i = previous_end + 1, pair.q_start - 1 do
      local line = all_lines[i]
      if line and line:match '%S' and not line:match '^[QA]:' then
        override_settings = parse_defaults(line)
        break
      end
    end

    -- Use override settings if available
    local qa_deck = override_settings and override_settings.deck or section_deck
    local qa_tags = override_settings and table.concat(override_settings.tags, ' ') or section_tags
    local qa_use_markdown = force_markdown or (override_settings and override_settings.use_markdown) or section_use_markdown

    -- Extract and format Q/A pair
    local qa_pair = extract_qa_pair(all_lines, pair.q_start, pair.a_start, pair.end_index, qa_use_markdown)
    local note = format_note(qa_deck, qa_tags, qa_pair.question, qa_pair.answer, qa_use_markdown)

    table.insert(all_notes, {
      pair = pair,
      note_lines = vim.split(note, '\n'),
    })

    previous_end = pair.end_index
  end

  -- Generate new buffer content
  local new_content = {}
  local current_pos = 1

  for _, note_info in ipairs(all_notes) do
    local pair = note_info.pair

    -- Add content between current position and this pair
    for i = current_pos, pair.q_start - 1 do
      table.insert(new_content, all_lines[i])
    end

    -- Add formatted note
    vim.list_extend(new_content, note_info.note_lines)
    table.insert(new_content, '')  -- Add blank line after note

    current_pos = pair.end_index + 1
  end

  -- Add remaining content after last pair
  for i = current_pos, #all_lines do
    table.insert(new_content, all_lines[i])
  end

  -- Update buffer
  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_content)
  vim.cmd 'update'
end

-- Add a new function specifically to process all Q/A pairs in the section
function M.create_all_notes(options)
  options = options or {}
  options.process_all = true
  M.create_notes(options)
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
_G.create_all_notes = M.create_all_notes
_G.paste_image_to_anki = M.paste_image_to_anki
_G.run_apy_add_from_file = M.run_apy_add_from_file
_G.run_apy_update_from_file = M.run_apy_update_from_file

vim.keymap.set('n', '<leader>ac', '<cmd>lua create_all_notes()<CR>', { noremap = true, silent = true, desc = '[C]reate Notes' })
vim.keymap.set('n', '<leader>ap', '<cmd>lua paste_image_to_anki()<CR>', { noremap = true, silent = true, desc = '[P]aste image' })
vim.keymap.set('n', '<leader>aa', '<cmd>lua run_apy_add_from_file()<CR>', { noremap = true, silent = true, desc = '[A]dd notes' })
vim.keymap.set('n', '<leader>au', '<cmd>lua run_apy_update_from_file()<CR>', { noremap = true, silent = true, desc = '[U]pdate from note' })

-- Return the module table
return M
