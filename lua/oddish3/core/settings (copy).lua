-- Global settings and mappings
vim.api.nvim_exec([[
    setlocal spell
    set spelllang=en_gb
    inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
]], false)

--vnoremap <C-r> :s/\%V\<\(\w\)\(\w*\)\%V/\u\1\2/g<CR>

-- colourscheme 
vim.cmd[[colorscheme tokyonight]]
vim.cmd[[set clipboard^=unnamed,unnamedplus]]

-- Map the toggle of the quickfix list to a keybinding, e.g., <leader>q, using an inline function
vim.api.nvim_set_keymap('n', '<leader>q', '', {
    noremap = true,
    silent = true,
    callback = function()
        -- Get the list of all windows
        local windows = vim.fn.getwininfo()
        local isQuickfixOpen = false

        -- Check if any window is a quickfix window
        for _, win in pairs(windows) do
            if win.quickfix == 1 then
                isQuickfixOpen = true
                break
            end
        end

        -- Toggle the quickfix window based on its current state
        if isQuickfixOpen then
            vim.cmd('cclose')
        else
            vim.cmd('copen')
        end
    end
})


-- key mappings
--GC
-- Properly map keys to Vimtex commands
vim.api.nvim_set_keymap('n', 'csm', '<Plug>(vimtex-env-change-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dsm', '<Plug>(vimtex-env-delete-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dam', '<Plug>(vimtex-delim-delete-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dim', '<Plug>(vimtex-delim-change-math)', { noremap = true, silent = true })

-- Toggle environment with 'm'
vim.api.nvim_set_keymap('n', 'tsm', '<Plug>(vimtex-env-toggle-math)', { noremap = true, silent = true })

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



--prime
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--vim.keymap.set("n", "<leader>vwm", function()
--    require("vim-with-me").StartVimWithMe()
--end)
--vim.keymap.set("n", "<leader>svwm", function()
--    require("vim-with-me").StopVimWithMe()
--end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
--vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- global
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gci<Left><Left><Left>]]) -- confirm

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }) --executable 

vim.keymap.set("n", "<leader>vpp", "<cmd>e /home/oddish3/.config/nvim/init.lua<CR>");
--vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

vim.opt.runtimepath:append("/home/oddish3/current_course")

-- telescope 

-- set keymaps
local keymap = vim.keymap -- for conciseness
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    
-- harpoon 
    
-- Set keymaps
local keymap = vim.keymap -- for conciseness

keymap.set('n', '<leader>hm', "<cmd>lua require('harpoon.mark').add_file()<CR>", { desc = "Mark file with harpoon" })
keymap.set('n', '<leader>hn', "<cmd>lua require('harpoon.ui').nav_next()<CR>", { desc = "Go to next harpoon mark" })
keymap.set('n', '<leader>hp', "<cmd>lua require('harpoon.ui').nav_prev()<CR>", { desc = "Go to previous harpoon mark" })
keymap.set('n', '<C-e>', function() toggle_telescope(require('harpoon.mark')) end, { desc = "Open harpoon window with Telescope" })

-- Corrected this line to avoid duplicate key mapping and to ensure correct functionality
-- keymap.set('n', '<leader>a', function() require('harpoon.mark').add_file() end) -- Potentially you meant to add a file here, adjust as needed

-- Correctly reference the 'ui' module and the 'toggle_quick_menu' function
keymap.set('n', '<C-e>', function() require('harpoon.ui').toggle_quick_menu() end, { desc = "Toggle Harpoon quick menu" })

-- These functions are not standard in Harpoon; ensure your custom implementations support them if used
 keymap.set('n', '<C-h>', function() harpoon:list():select(1) end)
 keymap.set('n', '<C-t>', function() harpoon:list():select(2) end)
 keymap.set('n', '<C-n>', function() harpoon:list():select(3) end)
 keymap.set('n', '<C-s>', function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list - Adjust if you have custom implementations
 keymap.set('n', '<C-S-P>', function() harpoon:list():prev() end)
 keymap.set('n', '<C-S-N>', function() harpoon:list():next() end)
