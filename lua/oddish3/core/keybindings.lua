-- keybindings.lua

---- vimtex
local keymap = vim.keymap

_G.my_custom_mappings = {}

_G.my_custom_mappings.ci_dollar = function()
    vim.cmd('normal ci$')
end

_G.my_custom_mappings.ca_dollar = function()
    vim.cmd('normal ca$')
end

_G.my_custom_mappings.vi_dollar = function()
    vim.cmd('normal vi$')
end

_G.my_custom_mappings.va_dollar = function()
    vim.cmd('normal va$')
end
vim.api.nvim_set_keymap('n', 'cim', ':lua _G.my_custom_mappings.ci_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'cam', ':lua _G.my_custom_mappings.ca_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vim', ':lua _G.my_custom_mappings.vi_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vam', ':lua _G.my_custom_mappings.va_dollar()<CR>', { noremap = true, silent = true })


-- Vimtex Mappings
-- Change environment to a math environment
keymap.set('n', 'csm', '<Plug>(vimtex-env-change-math)', { noremap = true, silent = true })
-- Delete the current math environment
keymap.set('n', 'dsm', '<Plug>(vimtex-env-delete-math)', { noremap = true, silent = true })
-- Delete delimiters around math content
keymap.set('n', 'dam', '<Plug>(vimtex-delim-delete-math)', { noremap = true, silent = true })
-- Change delimiters around math content
keymap.set('n', 'dim', '<Plug>(vimtex-delim-change-math)', { noremap = true, silent = true })
-- Toggle between inline and block math environments
keymap.set('n', 'tsm', '<Plug>(vimtex-env-toggle-math)', { noremap = true, silent = true })


-- General Navigation and Editing Enhancements
-- keymap.set("n", "<leader>pv", vim.cmd.Ex) -- directory nav
keymap.set("n", "<leader>vpp", "<cmd>e /home/oddish3/.config/nvim/init.lua<CR>"); --config nav
-- Move selected line/block of text in visual mode down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
-- Move selected line/block of text in visual mode up
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
-- Join lines without moving the cursor
keymap.set("n", "J", "mzJ`z", { silent = true })
-- Center screen after page-down
keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
-- Center screen after page-up
keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
-- Center screen on next search result
keymap.set("n", "n", "nzzzv", { silent = true })
-- Center screen on previous search result
keymap.set("n", "N", "Nzzzv", { silent = true })
-- Prevent use of ex-mode
keymap.set("n", "Q", "<nop>", { silent = true })

-- Scroll half-page down and recenter
keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
-- Scroll half-page up and recenter
keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
-- Jump to the next match and recenter
keymap.set("n", "n", "nzzzv", { silent = true })
-- Jump to the previous match and recenter
keymap.set("n", "N", "Nzzzv", { silent = true })
-- Paste and reselect in visual mode
keymap.set("x", "<leader>p", [["_dP]], { silent = true })
-- Yank to clipboard in normal and visual mode
keymap.set({"n", "v"}, "<leader>y", [["+y]], { silent = true })
-- Yank whole line to clipboard in normal mode
keymap.set("n", "<leader>Y", [["+Y]], { silent = true })
-- Delete without yanking in normal and visual mode
keymap.set({"n", "v"}, "<leader>d", [["_d]], { silent = true })
-- Cancel insert mode with Ctrl-c like in other applications
keymap.set("i", "<C-c>", "<Esc>", { silent = true })
-- Make the current file executable
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
-- Jump to the next and previous quickfix list items
--keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { silent = true })
--keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { silent = true })
-- Jump to the next and previous location list items
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { silent = true })
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { silent = true })
-- Search and replace the word under cursor globally
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = true })
-- Search and replace the word under cursor with confirmation
keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gci<Left><Left><Left>]], { silent = true })

---- Telescope Mappings
-- Fuzzy find files
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
-- Fuzzy find recently opened files
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
-- Live grep in current working directory
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
-- Find string under cursor in current working directory
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

local customTelescope = require('oddish3.utils.telescope-setup')
keymap.set("n", "<leader>fg", customTelescope.CustomLiveGrep, { desc = "Custom Live Grep" })

---- harpoon
keymap.set("n", "<C-e>", function() require('harpoon.ui').toggle_quick_menu() end)
keymap.set('n', '<ffb>', '<cmd>lua require("oddish3.utils.harpoon-telescope").search_marks()<CR>', { noremap = true, silent = true })

keymap.set(
      "n",
      "<leader>hm",
      "<cmd>lua require('harpoon.mark').add_file()<cr>",
      { desc = "Mark file with harpoon" }
    )
keymap.set("n", "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", { desc = "Go to next harpoon mark" })
keymap.set(
      "n",
      "<leader>hp",
      "<cmd>lua require('harpoon.ui').nav_prev()<cr>",
      { desc = "Go to previous harpoon mark" })
      
---- tab navigation 
keymap.set('n', '<leader>tn', ':tabnew<CR>', { noremap = true, silent = true, desc = 'Open a new tab' })
keymap.set('n', '<leader>tc', ':tabclose<CR>', { noremap = true, silent = true, desc = 'Close the current tab' })
keymap.set('n', '<leader>tl', ':tabnext<CR>', { noremap = true, silent = true, desc = 'Go to the next tab' })
keymap.set('n', '<leader>th', ':tabprev<CR>', { noremap = true, silent = true, desc = 'Go to the previous tab' })
      

---- cursor
-- Change cursor shape in insert mode to a vertical bar
vim.api.nvim_exec([[
  if has("nvim")
    let &t_SI = "\e[5 q" " Start Insert mode
    let &t_EI = "\e[1 q" " End Insert mode (back to block cursor in normal mode)
  endif
]], false)

-- Optionally, for replace mode, change to an underline cursor
vim.api.nvim_exec([[ let &t_SR = "\e[3 q" ]], false)   
   
---- spelling
-- Set up spell checking and language
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"


vim.api.nvim_create_autocmd("FileType", {
    pattern = {"tex", "markdown"},
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_gb"
    end
})

-- Function to trigger Telescope's spell suggest
--local function telescope_spell_suggest()
--  require('telescope.builtin').spell_suggest(
--    require('telescope.themes').get_cursor({
--      attach_mappings = function(_, map)
--        map({ 'i', 'n' }, '<C-y>', require('telescope.actions').select_default)
--        return true
--      end,
--    })
--  )
--end
-- Optional: Normal mode mapping to directly invoke spelling suggestions
--vim.keymap.set('n', '<C-i>', telescope_spell_suggest, { desc = 'Spelling Suggestions' })



_G.spell_suggest_last_error = function()
  -- Exit insert mode temporarily
  vim.cmd('stopinsert')
  -- Move to the last spelling error
  vim.cmd('normal! [s')
  -- Open spelling suggestions with Telescope
  require('telescope.builtin').spell_suggest(require('telescope.themes').get_cursor())
end

-- Insert mode mapping to invoke spelling suggestions at the last error
vim.api.nvim_set_keymap('i', '<C-i>', '<ESC>:lua _G.spell_suggest_last_error()<CR>', { noremap = true, silent = true })

-- Keep the existing mapping for correcting the last spelling error in insert mode
vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })


   
---- autocapitalisation 
local function autoCapitalize()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Adjust for Lua indexing
    local line = vim.api.nvim_get_current_line()
    local char = vim.api.nvim_get_vvar("char")

    -- Directly capitalize if at the start of the line
    if col == 1 then
        vim.api.nvim_set_vvar("char", char:upper())
    else
        local prev_two_chars = line:sub(col - 2, col - 1)
        local prev_chars_up_to_col = line:sub(1, col - 1)

        -- Capitalize after a period and a whitespace or directly after \item followed by a space
        if prev_two_chars:match("%.%s$") then
            vim.api.nvim_set_vvar("char", char:upper())
        elseif prev_chars_up_to_col:find("\\item%s+$") then
            -- When the cursor is right after \item and spaces, only capitalize the next character (already captured in 'char')
            vim.api.nvim_set_vvar("char", char:upper())
        end
    end
end

-- Set up the autocmd specifically for .tex files
function _G.processLaTeXFile()
    print("Function triggered")
    local path = vim.api.nvim_buf_get_name(0)
    local content = vim.fn.readfile(path)
    local changed = false

    for i, line in ipairs(content) do
        print("Original line: " .. line)  -- Print each line before change
        local new_line = line:gsub("\\(%w+)%s*{(.-)}", function(header, innerContent)
            print("Found header: " .. header)  -- Check which header is matched
            if header:match("^chapter$|^section$|^subsection$|^subsubsection$|^paragraph$|^subparagraph$") then
                local modifiedContent = innerContent:gsub("%f[%w](%w%w%w+)%f[%W]", function(word)
                    print("Capitalize word: " .. word)  -- Debug output for words being capitalized
                    return word:sub(1,1):upper() .. word:sub(2)
                end)
                print("Modified content: " .. modifiedContent)  -- Show modified content
                if modifiedContent ~= innerContent then
                    changed = true
                    return "\\" .. header .. "{" .. modifiedContent .. "}"
                end
            end
            return "\\" .. header .. "{" .. innerContent .. "}"
        end)
        if new_line ~= line then
            print("Modified line: " .. new_line)  -- Print changed line
            content[i] = new_line
        end
    end

    if changed then
        vim.fn.writefile(content, path)
        print("LaTeX headers capitalized and file updated.")
    else
        print("No changes needed.")
    end
end

--vim.cmd [[
--  augroup AutoCapitalizeTexHeaders
  --  autocmd!
    --autocmd BufReadPost,BufWritePre *.tex lua _G.processLaTeXFile()
  --augroup END
--]]
--


---- misc

vim.api.nvim_set_keymap('n', '<leader>tc', ':VimtexTocToggle<CR>', {noremap = true, silent = true})

-- Quickfix List Toggle
-- Toggle the visibility of the quickfix list
keymap.set('n', '<leader>qf', '', {
    noremap = true,
    silent = true,
    callback = function()
        local windows = vim.fn.getwininfo()
        local isQuickfixOpen = false
        for _, win in pairs(windows) do
            if win.quickfix == 1 then
                isQuickfixOpen = true
                break
            end
        end
        if isQuickfixOpen then
            vim.cmd('cclose')
        else
            vim.cmd('copen')
        end
    end
})

vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
   
      
--vim.keymap.set("n", "<C-t>", "<cmd>silent !tmux neww ~/scripts/nvim/tmux-sessionizer.sh<CR>", { noremap = true, silent = true })
   
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("source ~/.config/nvim/init.lua")
end, { noremap = true, silent = true })

----  Alpha dashboard

vim.api.nvim_set_keymap('n', 'zz', ':Alpha<CR>', { noremap = true, silent = true })

---- toggle term
local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
 return
end

toggleterm.setup({
 size = 20,
 open_mapping = [[<c-\>]],
 hide_numbers = true,
 shade_filetypes = {},
 shade_terminals = true,
 shading_factor = 2,
 start_in_insert = true,
 insert_mappings = true,
 persist_size = true,
 direction = "float",
 close_on_exit = true,
 shell = vim.o.shell,
 float_opts = {
  border = "curved",
  winblend = 0,
  highlights = {
   border = "Normal",
   background = "Normal",
  },
 },
})

function _G.set_terminal_cwd()
  -- Get the directory of the current file
  local file_dir = vim.fn.expand('%:p:h')

  -- Define the command to open toggleterm and change to the file's directory
  local cmd = "cd " .. file_dir .. " && " .. vim.o.shell
  
  -- Setup toggleterm terminal with the specific command
  require("toggleterm.terminal").Terminal:new({
    cmd = cmd,
    direction = "float",
    close_on_exit = true,
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-z>", "<cmd>close<CR>", {noremap = true, silent = true})
    end,
  }):toggle()
end

vim.api.nvim_set_keymap('n', '<c-x>', ':lua set_terminal_cwd()<CR>', {noremap = true, silent = true})


---- nav

vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', {noremap = true, silent = true})

-- anki
--require('oddish3.utils.anki_math_zone')
--require('cmp_vimtex').setup()


-- cmp vimtex
vim.api.nvim_set_keymap('i', '<C-s>', '<cmd>lua require("cmp_vimtex.search").search_menu()<CR>', { noremap = true, silent = true })




-- Clear previous autocommands in the 'focus' group and recreate the group
local group = vim.api.nvim_create_augroup('focus', { clear = true })

-- Autocommand that exits insert mode when focus is lost
vim.api.nvim_create_autocmd('FocusLost', {
    group = group,
    pattern = '*',
    callback = function()
        if vim.fn.mode() == 'i' then
            vim.cmd('stopinsert')
        end
    end
})

-- Autocommand that enters insert mode when focus is gained
vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    pattern = '*',
    callback = function()
        if vim.fn.getcmdwintype() == '' then
            vim.cmd('startinsert')
        end
    end
})
