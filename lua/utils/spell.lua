local M = {}

-- Set spell checking to British English
vim.o.spell = true
vim.o.spelllang = 'en_gb'

-- Create a function that adds both code block spell exclusion methods
local function no_spell_in_code()
  -- Only for relevant file types
  local ft = vim.bo.filetype
  if ft ~= 'markdown' and ft ~= 'quarto' and ft ~= 'rmd' then
    return
  end
  
  -- Make absolutely sure we add this option
  vim.opt_local.spellcapcheck = ''
  
  -- Add syntax rules with the highest priority possible
  pcall(function()
    vim.cmd([[
      syntax clear
      syntax sync fromstart
      
      " Basic markdown elements 
      syntax region markdownCode start=/```/ end=/```/ contains=@NoSpell keepend
      syntax region markdownCode start=/`/ end=/`/ contains=@NoSpell oneline
      syntax region mathBlock start=/\$\$/ end=/\$\$/ contains=@NoSpell keepend
      syntax region mathInline start=/\$/ end=/\$/ contains=@NoSpell oneline
      syntax region quartoCode start=/```{/ end=/```/ contains=@NoSpell keepend
      
      " Force highest priority to our rules
      syntax sync maxlines=100
      hi def link markdownCode Comment
      hi def link mathBlock Comment
      hi def link mathInline Comment
      hi def link quartoCode Comment
    ]])
  end)
end

-- Set up multiple events to ensure this runs
local spell_group = vim.api.nvim_create_augroup("ForceNoSpellInCode", { clear = true })

-- Apply on various events
vim.api.nvim_create_autocmd({"BufReadPost", "BufWritePost", "BufEnter", "FileType"}, {
  pattern = {"*.md", "*.qmd", "*.rmd"},
  callback = function()
    -- Add a small delay to ensure this runs after other plugins
    vim.defer_fn(no_spell_in_code, 100)
  end,
  group = spell_group,
})

-- Manual command
vim.api.nvim_create_user_command("NoSpellInCode", no_spell_in_code, {})


-- Function to check if current position is in code block
-- function M.is_in_code_block()
--   local pos = vim.api.nvim_win_get_cursor(0)
--   local line = pos[1]
--   local col = pos[2] + 1
--
--   -- Get syntax ID at current position
--   local syntax_id = vim.fn.synID(line, col, 1)
--   local syntax_name = vim.fn.synIDattr(syntax_id, "name")
--
--   -- Check if syntax name contains any code-related terms
--   return syntax_name:match("Code") or
--          syntax_name:match("Math") or
--          syntax_name:match("markdownCodeBlock") or
--          syntax_name:match("quartoCodeBlock") or
--          syntax_name:match("markdownMathBlock") or
--          syntax_name:match("markdownInlineMath") or
--          syntax_name:match("quartoInlineCode")
-- end
--
-- -- Custom spell checker that ignores code blocks
-- M.spell_check_ignoring_code = function()
--   -- If we're in a code block, do nothing
--   if M.is_in_code_block() then
--     print("In code block - ignoring spell check")
--     return
--   end
--
--   -- Save current position
--   local start_pos = vim.api.nvim_win_get_cursor(0)
--
--   -- Try to find misspelled word
--   local had_spell_error = pcall(function() vim.cmd("normal! [s") end)
--
--   -- If no error, we found a misspelled word
--   if had_spell_error then
--     -- Get new position after [s
--     local new_pos = vim.api.nvim_win_get_cursor(0)
--
--     -- Check if new position is in code block
--     if M.is_in_code_block() then
--       -- If in code block, go back to original position
--       vim.api.nvim_win_set_cursor(0, start_pos)
--       print("Spell error is in code block - ignoring")
--       return
--     else
--       -- Fix spelling and return to insert mode
--       vim.cmd("normal! 1z=`]a")
--     end
--   else
--     -- No spelling error found
--     vim.api.nvim_win_set_cursor(0, start_pos)
--     print("No spelling errors found")
--   end
-- end
--
-- -- Set up for quarto files only
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "quarto",
--   callback = function()
--     -- Make function available globally
--     _G.spell_check_ignoring_code = M.spell_check_ignoring_code
--
--     -- Set buffer-local mapping
--     vim.api.nvim_buf_set_keymap(
--       0,
--       'i',
--       '<C-l>',
--       '<cmd>lua spell_check_ignoring_code()<CR>',
--       { noremap = true, silent = true }
--     )
--   end
-- })
--
-- -- Default mapping for other filetypes
vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })

return M
