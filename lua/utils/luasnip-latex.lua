local M = {}

-- Try to get the plugin
local latex_snippets_ok, latex_snippets = pcall(require, 'luasnip-latex-snippets')

-- Define utility functions
function M.in_mathzone()
  if latex_snippets_ok then
    return latex_snippets.is_in_math()
  end
  return false -- Default if plugin not available
end

function M.not_in_mathzone()
  return not M.in_mathzone() and M.not_in_code_block()
end

function M.in_code_block()
  if latex_snippets_ok then
    return latex_snippets.is_in_code_block()
  end
  return false
end

function M.not_in_code_block()
  return not M.in_code_block()
end

-- More helper functions can be added here

return M
