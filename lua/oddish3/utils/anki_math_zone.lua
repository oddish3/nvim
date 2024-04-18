local M = {}

function M.anki_math_zone()
    local start_pattern = "\\[%$\\]" -- Simplified pattern for inline markers
    local end_pattern = "\\[%/%$\\]" -- Simplified pattern for inline markers

    -- Retrieve the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num, col = cursor_pos[1], cursor_pos[2] + 1 -- Adjust for Lua indexing

    -- Search for start and end positions of the markers
    local start_pos = vim.fn.searchpos(start_pattern, 'bnW')
    local end_pos = vim.fn.searchpos(end_pattern, 'nW')

    print("Cursor Pos: ", line_num, col) -- Debugging
    print("Start Pos: ", start_pos[1], start_pos[2]) -- Debugging
    print("End Pos: ", end_pos[1], end_pos[2]) -- Debugging

    -- Adjust logic to use cursor position for more accurate detection
    if start_pos[1] ~= 0 and end_pos[1] ~= 0 and
       start_pos[1] <= line_num and end_pos[1] >= line_num then
        if (start_pos[1] < line_num or (start_pos[1] == line_num and start_pos[2] < col)) and
           (end_pos[1] > line_num or (end_pos[1] == line_num and end_pos[2] > col)) then
            print("Within Anki Markers: True")
            return true
        end
    end

    print("Within Anki Markers: False")
    return false
end

return M

