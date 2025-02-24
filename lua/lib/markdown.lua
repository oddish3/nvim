-- lib/markdown.lua
-- lib/markdown.lua
-- lib/markdown.lua
local M = {}

-- Global state for math mode
M.math_mode_enabled = false

-- Toggle function that also shows status in buffer
function M.toggle_math_mode()
    M.math_mode_enabled = not M.math_mode_enabled
    local status = M.math_mode_enabled and "ON" or "OFF"
    
    -- Show status in current buffer
    local msg = "Math Mode: " .. status
    vim.api.nvim_echo({{msg, "WarningMsg"}}, true, {})
    
    -- Optional: Also show in command line
    print(msg)
    
    return M.math_mode_enabled
end

function M.in_mathzone()
    return M.math_mode_enabled
end

return M
