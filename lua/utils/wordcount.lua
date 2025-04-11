-- In your utils/wordcount.lua file
local M = {}

-- Function to format numbers with comma separators
local function group_number(num, sep)
  local formatted = tostring(num)
  local k = 3
  while k < #formatted do
    formatted = formatted:sub(1, #formatted - k) .. sep .. formatted:sub(#formatted - k + 1)
    k = k + 4 -- Adjust for the separator
  end
  return formatted
end

-- Function to get word count information for statusline - words only
function M.get_word_count_info()
  -- Only show word count for markdown files
  if vim.bo.filetype ~= 'markdown' then
    return ''
  end

  local mode = vim.api.nvim_get_mode().mode
  local wc = vim.fn.wordcount()

  if mode == 'v' or mode == 'V' or mode == '' then
    if wc.visual_words then
      return group_number(wc.visual_words, ',') .. ' words'
    end
  end

  return group_number(wc.words, ',') .. ' words'
end

return M
