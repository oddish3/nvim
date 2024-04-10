local function auto_capitalize()
    -- The pattern matches the start of the file, after punctuation followed by spaces, line starts with '-', starts with 'title: ', or after two newlines
    local pattern = '\\v(%^|[.!?]\\_s+|\\_^\\-\\s|\\_^title:\\s|\\n\\n)%#'
    -- Check if the pattern is found before the cursor position
    if vim.fn.search(pattern, 'bcnw') ~= 0 then
        -- Change the next character to uppercase
        vim.api.nvim_set_var('char', vim.fn.toupper(vim.api.nvim_get_var('char')))
    end
end

-- Create or clear the augroup
local augroup_id = vim.api.nvim_create_augroup('SENTENCES', { clear = true })

-- Register the autocmd
vim.api.nvim_create_autocmd('InsertCharPre', {
    group = augroup_id,
    pattern = '*',
    callback = auto_capitalize,
})
