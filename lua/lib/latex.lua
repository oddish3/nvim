-- lib/latex.lua
local M = {}

function M.in_mathzone()
    local debug_file = io.open("/tmp/lua_mathzone_debug.log", "a")
    local function log(msg)
        if debug_file then
            debug_file:write(os.date("%Y-%m-%d %H:%M:%S ") .. msg .. "\n")
            debug_file:flush()
        end
    end

    log("in_mathzone called")

    -- Get cursor position
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    cursor_row = cursor_row - 1  -- Convert to 0-based
    
    -- Get current line and surrounding lines
    local lines = vim.api.nvim_buf_get_lines(0, math.max(0, cursor_row - 1), cursor_row + 2, false)
    local current_line = lines[2] or lines[1] -- Current line should be in the middle if we got 3 lines

    if not current_line then
        log("No current line found")
        if debug_file then debug_file:close() end
        return '0'
    end

    -- Check for inline math on current line
    local pos = 1
    while pos <= #current_line do
        local s = current_line:find("%$", pos)
        if not s then break end
        
        -- Check if it's display math ($$)
        if current_line:sub(s, s + 1) == "$$" then
            pos = s + 2
        else
            -- Single $ found, look for closing $
            local e = current_line:find("%$", s + 1)
            if e then
                if cursor_col >= s - 1 and cursor_col <= e - 1 then
                    log(string.format("Found inline math: %s", current_line:sub(s, e)))
                    if debug_file then debug_file:close() end
                    return '1'
                end
                pos = e + 1
            else
                pos = s + 1
            end
        end
    end

    -- Check for display math
    local in_display = false
    for i, line in ipairs(lines) do
        if line:find("%$%$") then
            in_display = not in_display
        end
        if in_display and i == 2 then -- if we're in display math and on the current line
            log("Found display math")
            if debug_file then debug_file:close() end
            return '1'
        end
    end

    log("No math zone detected")
    if debug_file then debug_file:close() end
    return '0'
end

return M
