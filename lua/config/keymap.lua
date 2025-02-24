-- required in which-key plugin spec in plugins/ui.lua as `require 'config.keymap'`
local wk = require 'which-key'
local ms = vim.lsp.protocol.Methods

P = vim.print

vim.g['quarto_is_r_mode'] = nil
vim.g['reticulate_running'] = false

local nmap = function(key, effect)
  vim.keymap.set('n', key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set('v', key, effect, { silent = true, noremap = true })
end

local imap = function(key, effect)
  vim.keymap.set('i', key, effect, { silent = true, noremap = true })
end

local cmap = function(key, effect)
  vim.keymap.set('c', key, effect, { silent = true, noremap = true })
end

-- move in command line
cmap('<C-a>', '<Home>')

-- save with ctrl+s
imap('<C-s>', '<esc>:update<cr><esc>')
nmap('<C-s>', '<cmd>:update<cr><esc>')

-- Move between windows using <ctrl> direction
nmap('<C-j>', '<C-W>j')
nmap('<C-k>', '<C-W>k')
nmap('<C-h>', '<C-W>h')
nmap('<C-l>', '<C-W>l')

-- Resize window using <shift> arrow keys
nmap('<S-Up>', '<cmd>resize +2<CR>')
nmap('<S-Down>', '<cmd>resize -2<CR>')
nmap('<S-Left>', '<cmd>vertical resize -2<CR>')
nmap('<S-Right>', '<cmd>vertical resize +2<CR>')

-- Add undo break-points
imap(',', ',<c-g>u')
imap('.', '.<c-g>u')
imap(';', ';<c-g>u')
nmap('Q', '<Nop>')



-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- center after search and jumps
nmap('n', 'nzz')
nmap('<c-d>', '<c-d>zz')
nmap('<c-u>', '<c-u>zz')

-- move between splits and tabs
nmap('<c-h>', '<c-w>h')
nmap('<c-l>', '<c-w>l')
nmap('<c-j>', '<c-w>j')
nmap('<c-k>', '<c-w>k')
nmap('H', '<cmd>tabprevious<cr>')
nmap('L', '<cmd>tabnext<cr>')

local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end


--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
    { "<c-LeftMouse>", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "go to definition" },
    { "<c-q>", "<cmd>q<cr>", desc = "close buffer" },
    { "<esc>", "<cmd>noh<cr>", desc = "remove search highlight" },
    { "[q", ":silent cprev<cr>", desc = "[q]uickfix prev" },
    { "]q", ":silent cnext<cr>", desc = "[q]uickfix next" },
    { "gN", "Nzzzv", desc = "center search" },
    { "gf", ":e <cfile><CR>", desc = "edit file" },
    { "gl", "<c-]>", desc = "open help link" },
    { "n", "nzzzv", desc = "center search" },
    { "z?", ":setlocal spell!<cr>", desc = "toggle [z]pellcheck" },
    { "zl", ":Telescope spell_suggest<cr>", desc = "[l]ist spelling suggestions" },
}, { mode = 'n', silent = true })

-- visual mode
wk.add({
    {
      mode = { "v" },
      { ".", ":norm .<cr>", desc = "repat last normal mode command" },
      { "<M-j>", ":m'>+<cr>`<my`>mzgv`yo`z", desc = "move line down" },
      { "<M-k>", ":m'<-2<cr>`>my`<mzgv`yo`z", desc = "move line up" },
      { "q", ":norm @q<cr>", desc = "repat q macro" },
    },
})

-- visual with <leader>
wk.add({
    { "<leader>d", '"_d', desc = "delete without overwriting reg", mode = "v" },
    { "<leader>p", '"_dP', desc = "replace without overwriting reg", mode = "v" },
}, { mode = 'v' })

-- insert mode
wk.add({
    {
      mode = { "i" },
      { "<c-x><c-x>", "<c-x><c-o>", desc = "omnifunc completion" },
      { "<m-->", " <- ", desc = "assign" },
      { "<m-m>", " |>", desc = "pipe" },
    },
}, { mode = 'i' })

local function new_terminal(lang)
  vim.cmd('split term://' .. lang)
  -- Optional: if you want to set a specific height
  vim.cmd('resize 10')  -- adjust 15 to whatever height you prefer
  -- Optional: to keep the height fixed
  vim.cmd('set winfixheight')
end


local function new_terminal_shell()
  new_terminal '$SHELL'
end

-- normal mode with <leader>
wk.add({
  {
    { "<leader>a", group = "[a]nki" },
    { "<leader>b", group = "[b]uffer" },
    { "<leader>c", group = "[l]ist" },
    { "<leader>dt", group = "[t]est" },
    { "<leader>e", group = "[e]dit" },
    { "<leader>n", group = "[n]ew" },
    { "<leader>s", group = "[s]tata" },
    { "<leader>t", group = "[t]erminal / file[t]ype" },
    { "<leader>f", group = "[f]ind (telescope)" },
    -- { "<leader>f<space>", "<cmd>Telescope buffers<cr>", desc = "[ ] buffers" },
    -- { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "[M]an pages" },
    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[b]uffer fuzzy find" },
    { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "git [c]ommits" },
    { "<leader>fd", "<cmd>Telescope buffers<cr>", desc = "[d] buffers" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[f]iles" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "[g]rep" },
    -- { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "[h]elp" },
    -- { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "[j]umplist" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "[k]eymaps" },
    -- { "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "[l]oclist" },
    -- { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "[m]arks" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "[q]uickfix" },
    { "<leader>g", group = "[g]it" },
    { "<leader>gb", group = "[b]lame" },
    -- { "<leader>gbb", ":GitBlameToggle<cr>", desc = "[b]lame toggle virtual text" },
    -- { "<leader>gbc", ":GitBlameCopyCommitURL<cr>", desc = "[c]opy" },
    -- { "<leader>gbo", ":GitBlameOpenCommitURL<cr>", desc = "[o]pen" },
    -- { "<leader>gc", ":GitConflictRefresh<cr>", desc = "[c]onflict" },
    -- { "<leader>gd", group = "[d]iff" },
    -- { "<leader>gdc", ":DiffviewClose<cr>", desc = "[c]lose" },
    -- { "<leader>gdo", ":DiffviewOpen<cr>", desc = "[o]pen" },
    -- { "<leader>gs", ":Gitsigns<cr>", desc = "git [s]igns" },
    -- { "<leader>gwc", ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", desc = "worktree create" },
    -- { "<leader>gws", ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", desc = "worktree switch" },
    -- { "<leader>h", group = "[h]elp / [h]ide / debug" },
    -- { "<leader>hc", group = "[c]onceal" },
    -- { "<leader>hch", ":set conceallevel=1<cr>", desc = "[h]ide/conceal" },
    -- { "<leader>hcs", ":set conceallevel=0<cr>", desc = "[s]how/unconceal" },
    -- { "<leader>ht", group = "[t]reesitter" },
    -- { "<leader>htt", vim.treesitter.inspect_tree, desc = "show [t]ree" },
    { "<leader>i", group = "[i]mage" },
    { "<leader>l", group = "[l]anguage" },
    -- { "<leader>ld", group = "[d]iagnostics" },
    -- { "<leader>ldd", function() vim.diagnostic.enable(false) end, desc = "[d]isable" },
    -- { "<leader>lde", vim.diagnostic.enable, desc = "[e]nable" },
    -- { "<leader>le", vim.diagnostic.open_float, desc = "diagnostics (show hover [e]rror)" },
    -- { "<leader>lg", ":Neogen<cr>", desc = "neo[g]en docstring" },
    -- { "<leader>o", group = "[o]tter & c[o]de" },
    -- { "<leader>q", group = "[q]uarto" },
    -- { "<leader>qa", ":QuartoActivate<cr>", desc = "[a]ctivate" },
    -- { "<leader>qh", ":QuartoHelp ", desc = "[h]elp" },
    -- { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review" },
    -- { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uiet preview" },
    -- { "<leader>qr", group = "[r]un" },
    -- { "<leader>qra", ":QuartoSendAll<cr>", desc = "run [a]ll" },
    -- { "<leader>qrb", ":QuartoSendBelow<cr>", desc = "run [b]elow" },
    -- { "<leader>qrr", ":QuartoSendAbove<cr>", desc = "to cu[r]sor" },
    -- { "<leader>r", group = "[r] R specific tools" },
    -- { "<leader>rt", show_r_table, desc = "show [t]able" },
    { "<leader>v", group = "[v]im" },
    { "<leader>vc", ":Telescope colorscheme<cr>", desc = "[c]olortheme" },
    -- { "<leader>vh", ':execute "h " . expand("<cword>")<cr>', desc = "vim [h]elp for current word" },
    { "<leader>vl", ":Lazy<cr>", desc = "[l]azy package manager" },
    -- { "<leader>vm", ":Mason<cr>", desc = "[m]ason software installer" },
    { "<leader>vs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>", desc = "[s]ettings, edit vimrc" },
    { "<leader>vt", toggle_light_dark_theme, desc = "[t]oggle light/dark theme" },
    { "<leader>x", group = "e[x]ecute" },
    { "<leader>xx", ":w<cr>:source %<cr>", desc = "[x] source %" },
    { "<leader>z", group = "[z]otero" },
  }
}, { mode = 'n'})


 -- my mappings

wk.add({
  -- Pandoc group
  {
    "<leader>p", desc = "PANDOC"
  },
  {
    "<leader>pw", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx'<CR>", desc = "[w]ord"
  },
  {
    "<leader>pm", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.md'<CR>", desc = "[m]arkdown"
  },
  {
    "<leader>ph", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.html'<CR>", desc = "[h]tml"
  },
  {
    "<leader>pl", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.tex'<CR>", desc = "[l]atex"
  },
  {
    "<leader>pp", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.pdf' open=0<CR>", desc = "[p]df"
  },
  {
  "<leader>pi", "<cmd>TermExec cmd='source /Users/user/venv/bin/activate.fish && " ..
    "pandoc %:p -t markdown --wrap=none -o %:p:r.md && " ..
    "sentence-splitter %:p:r.md %:p:r_split.md'<CR>", 
  desc = "[i]mport docx + split"
},
{
  "<leader>pz", "<cmd>TermExec cmd='source /Users/user/venv/bin/activate.fish && " ..
    "pandoc %:p -s -o %:p:r.docx -F /Users/user/.local/share/nvim/lazy/zotcite/python3/zotref.py --citep'<CR>", 
  desc = "[z]otcite export"
},
{
  "<leader>pv", "<cmd>TermExec cmd='source /Users/user/venv/bin/activate.fish && " ..
    "pandoc %:p -s -o %:p:r.docx -F /Users/user/.local/share/nvim/lazy/zotcite/python3/zotref.py --citep --csl /Users/user/Zotero/styles/vancouver-brackets-only-year-no-issue.csl'<CR>", 
  desc = "[v]ancouver export"
},
}, { mode = 'n' })


-- quartz
-- Load the ToggleTerm module
local Terminal = require("toggleterm.terminal").Terminal

-- Define the command for Quartz preview mode
local quartz_preview = Terminal:new({
  cmd = "export QUARTZ_MODE=preview && npx quartz build --serve --verbose --bundleInfo", -- Prepend export command
  hidden = false,
  direction = "horizontal",
  size = 10,
  on_open = function(term)
    vim.cmd("startinsert!")
  end,
  on_close = function(term)
    -- Optional: Add any cleanup or notification if needed
  end,
})

-- Define the command for Quartz preview-build mode (if needed - depends on what you want this to do)
local quartz_preview_build = Terminal:new({
  cmd = "npx quartz build --serve --verbose --bundleInfo", -- Prepend export command
  hidden = false,
  direction = "horizontal",
  size = 10,
  on_open = function(term)
    vim.cmd("startinsert!")
  end,
  on_close = function(term)
    -- Optional: Add any cleanup or notification if needed
  end,
})

-- Function to toggle the Quartz preview terminal
local function toggle_quartz_preview()
  quartz_preview:toggle()
end

-- Function to toggle the Quartz preview-build terminal
local function toggle_quartz_preview_build()
  quartz_preview_build:toggle()
end

-- Create Neovim user commands for Quartz preview modes
vim.api.nvim_create_user_command("QuartzPreview", function()
  toggle_quartz_preview()
end, {
})

vim.api.nvim_create_user_command("QuartzPreviewBuild", function()
  toggle_quartz_preview_build()
end, {
})

-- Set up keybindings for initiating and toggling the Quartz server
wk.add({
    { "<leader>qP", ":QuartzPreviewBuild<CR>", desc = "Toggle Quartz [P]ublic preview mode" },
    { "<leader>qp", ":QuartzPreview<CR>", desc = "Toggle Quartz [p]review mode" },
}, { mode = 'n', silent = true })


-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
--
--

local keymap = vim.keymap
-- Make the current file executable
keymap.set("n", "<leader>xx", "<cmd>!chmod +x %<CR>", { silent = true })
  
-- Open .docx files in Word
vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.docx",
    callback = function(args)
        local filename = args.name
        local filepath = vim.fn.expand(filename)

        print("BufReadCmd triggered for:", filepath) -- DEBUG 1: Check if autocommand is triggered
        print("Filepath (expanded):", filepath) -- DEBUG 2: Check expanded filepath

        -- Check if we are actually trying to open a .docx file
        if filepath:lower():match("%.docx$") then
            print("File is a .docx file") -- DEBUG 3: Check if extension check works

            vim.cmd("silent edit! ++filetype=empty " .. filename) -- Force empty filetype
            print("Filetype set to empty") -- DEBUG 4: Check if filetype is set

            -- Open the file in Microsoft Word
            local job_id = vim.fn.jobstart({"open", "-a", "Microsoft Word", filepath}, {
                on_exit = function(job_id, data, event)
                    print("Job finished, exit code:", data.exit_code) -- DEBUG 5: Check job exit code
                    if data.exit_code == 0 then
                        vim.cmd("bd!") -- Close the buffer after opening externally
                        print("Buffer closed") -- DEBUG 6: Check if buffer is closed
                    else
                        print("Error opening Word, exit code:", data.exit_code) -- DEBUG 7: Check for errors
                    end
                end
            })
             print("Job started, job ID:", job_id) -- DEBUG 8: Check if job started

            -- Stop further processing - trying both stopautocmd and explicit return
            vim.cmd("stopautocmd")
            print("stopautocmd executed") -- DEBUG 9: Check if stopautocmd is executed
            return -- Explicitly return to stop further processing in Lua too.


        else
            print("File is NOT a .docx file (shouldn't happen for *.docx pattern in BufReadCmd)") -- DEBUG 10: Should not reach here for *.docx
        end
        print("Callback finished normally (shouldn't reach here if stopautocmd works for .docx)") -- DEBUG 11: Should not reach here for .docx

    end,
})

vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })

-- Normal mode mappings (your existing ones)
-- vim.api.nvim_set_keymap('n', '<Leader>p', '"0p', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>P', '"0P', { noremap = true, silent = true })

-- Visual mode mappings (new ones that use black hole register)
vim.api.nvim_set_keymap('v', '<Leader>p', '"_d"0P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>P', '"_d"0P', { noremap = true, silent = true })

-- Mapping for next buffer
vim.api.nvim_set_keymap('n', '<Leader>bn', ':bnext<CR>', { noremap = true, silent = true })

-- Mapping for previous buffer
vim.api.nvim_set_keymap('n', '<Leader>bp', ':bprevious<CR>', { noremap = true, silent = true })

-- Mapping to close the current buffer
vim.api.nvim_set_keymap('n', '<Leader>bd', ':bdelete<CR>', { noremap = true, silent = true })

-- Function to check if the current line is within a code block or YAML front matter
local function is_in_special_block(line_num)
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local in_code_block = false
    local in_frontmatter = false
    for i = 1, line_num do
        local line = lines[i]
        if line:match("^%-%-%-%s*$") then
            in_frontmatter = not in_frontmatter
        elseif line:match("^```") then
            in_code_block = not in_code_block
        end
        if i == line_num then
            break
        end
    end
    return in_code_block or in_frontmatter
end

-- Auto-capitalization function
local function auto_capitalize_md()
    local pos = vim.api.nvim_win_get_cursor(0)
    local line_num = pos[1]
    local col_num = pos[2]
    local line = vim.api.nvim_get_current_line()
    local char = vim.v.char

    -- Early exit if in code block or front matter
    if is_in_special_block(line_num) then
        return
    end

    -- Capitalize first character of the line
    if col_num == 0 then
        vim.v.char = char:upper()
        return
    end

    -- Get the character before the cursor
    local prev_char = line:sub(col_num, col_num)
    local trimmed_line = line:sub(1, col_num):match("^%s*(.-)%s*$")

    -- Patterns after which to capitalize
    local patterns = {
        "%.$",  -- Period
        "%?$",  -- Question mark
        "!$",   -- Exclamation mark
        "^#+%s*$",  -- Heading markers
        "^%s*%-%s*$",  -- Markdown list
    }

    -- Check if previous character matches any pattern
    for _, pattern in ipairs(patterns) do
        if trimmed_line:match(pattern) then
            vim.v.char = char:upper()
            return
        end
    end
end

-- Register the function globally
_G.auto_capitalize_md = auto_capitalize_md

-- Setup autocommand for Markdown and Quarto filetypes
vim.cmd [[
  augroup AutoCapitalizeMd
    autocmd!
    autocmd InsertCharPre *.md,*.qmd lua _G.auto_capitalize_md()
  augroup END
]]
---- toggle term
local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
 return
end

toggleterm.setup({
 size = 10,
 open_mapping = [[<c-\>]],
 hide_numbers = true,
 shade_filetypes = {},
 shade_terminals = true,
 shading_factor = 2,
 start_in_insert = true,
 insert_mappings = true,
 persist_size = true,
 direction = "horizontal",
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
    direction = "horizontal",
    close_on_exit = true,
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<c-z>", "<cmd>close<CR>", {noremap = true, silent = true})
    end,
  }):toggle()
end

vim.api.nvim_set_keymap('n', '<Leader>tc', ':lua set_terminal_cwd()<CR>', {noremap = true, silent = true})

-- Define options for key mapping
local opts = { noremap = true, silent = true }

-- Kill search highlights
-- Then, set your own mapping for Enter
local opts = { noremap = true, silent = true } -- specify options if needed
vim.api.nvim_set_keymap('n', '<Esc>', ':noh<CR>', opts)

-- stata remove spell check
vim.api.nvim_create_autocmd("FileType", {
    pattern = "stata",
    callback = function()
        vim.opt_local.spell = false
    end,
})

vim.keymap.set("n", "<C-r>", "<cmd>redo<CR>", { noremap = true, silent = true })

-- open file_browser with the path of the current buffer
vim.keymap.set("n", "<space>e", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

-- Function to open Word documents using Microsoft Word
local function open_with_word(file_path)
  -- Escape the file path for shell execution
  local escaped_file_path = file_path:gsub("'", "\\'")
  -- Construct the shell command to open the file with Word
  local command = "open -a 'Microsoft Word' '" .. escaped_file_path .. "'"
  -- Execute the command
  os.execute(command)
end

-- Autocommand group to isolate the autocmd
vim.api.nvim_create_augroup('OpenWordDocs', { clear = true })

-- Autocommand to trigger on opening .doc and .docx files
vim.api.nvim_create_autocmd('BufReadPre', {
  group = 'OpenWordDocs',
  pattern = {'*.doc', '*.docx'},
  callback = function()
    local file_path = vim.fn.expand('<afile>:p')  -- Get the full file path
    open_with_word(file_path)  -- Call the function to open the file with Word
    vim.cmd('bdelete!')  -- Close the buffer in Neovim
  end
})

-- Import zotcite module
local zotcite = require("zotcite")

-- Override the `open_attachment` function in zotcite
zotcite.open_attachment = function()
    -- Get the current line under the cursor
    local line = vim.api.nvim_get_current_line()
    -- Get the column position of the cursor
    local col = vim.fn.col(".")

    -- Find the Zotero citation key nearest to the cursor
    local start_pos = string.find(string.sub(line, 1, col), "@%w+")
    local end_pos = string.find(string.sub(line, col), "%s") or #line + 1

    -- vim.api.nvim_echo({{"Looking for Zotero key...", "Normal"}}, true, {})

    if start_pos and end_pos then
        local zotkey = string.sub(line, start_pos + 1, col + end_pos - 2) -- shift start_pos by 1 to remove '@'

        -- Debug: Print the extracted Zotero key
        -- vim.api.nvim_echo({{"Extracted Zotero key: " .. zotkey, "Normal"}}, true, {})

        -- Ensure optional parts after the key (e.g., #Harrison_Etal-2015) are removed
        local item_key = string.match(zotkey, "([A-Z0-9]+)")

        -- Validate and construct Zotero URI
        if item_key then
            -- Construct the URI
            local zotero_uri = "zotero://select/library/items/" .. item_key

            -- Debug: Print the URI that will be opened
            -- vim.api.nvim_echo({{"Opening URI: " .. zotero_uri, "Normal"}}, true, {})

            -- Use `open` command on macOS to open the URI in Zotero
            vim.fn.jobstart({ "open", zotero_uri }, { detach = true })
        else
            -- vim.api.nvim_echo({{"Failed to construct Zotero URI from key: " .. (zotkey or "unknown"), "Error"}}, true, {})
        end
    else
        -- vim.api.nvim_echo({{"No valid Zotero key found under the cursor", "Error"}}, true, {})
    end
end

-- Map a key to trigger the function
-- Adjust the mapping to the keys you want to use, e.g., "<leader>z"
vim.api.nvim_set_keymap('n', '<leader>zz', ':lua require("zotcite").open_attachment()<CR>', { noremap = true, silent = true })

-- First define the text objects for math delimiters
vim.api.nvim_set_keymap('o', 'i$', ':<C-u>normal! T$vt$<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'a$', ':<C-u>normal! F$vf$<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'i$', ':<C-u>normal! T$vt$<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'a$', ':<C-u>normal! F$vf$<CR>', { noremap = true, silent = true })

-- Then your existing mappings should work
_G.my_custom_mappings = _G.my_custom_mappings or {}

_G.my_custom_mappings.ci_dollar = function()
    vim.cmd('normal! T$vt$c')
end

_G.my_custom_mappings.ca_dollar = function()
    vim.cmd('normal! F$vf$c')
end

_G.my_custom_mappings.vi_dollar = function()
    vim.cmd('normal! T$vt$')
end

_G.my_custom_mappings.va_dollar = function()
    vim.cmd('normal! F$vf$')
end

vim.api.nvim_set_keymap('n', 'cim', ':lua _G.my_custom_mappings.ci_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'cam', ':lua _G.my_custom_mappings.ca_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vim', ':lua _G.my_custom_mappings.vi_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vam', ':lua _G.my_custom_mappings.va_dollar()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>nf", function()
    local oil = require("oil")
    local date = vim.fn.strftime("%Y-%m-%d") .. ".md" -- Date-based filename

    -- Ensure we're inside an Oil buffer
    if not oil.get_current_dir() then
        vim.notify("Not inside an Oil buffer!", vim.log.levels.WARN)
        return
    end

    -- Simulate pressing `o` (new line), typing filename, and saving
    vim.api.nvim_feedkeys("o" .. date .. "\x1b:w\n", "n", false)
end, { desc = "Create and save a new markdown file with today's date in Oil", silent = true })

wk.add({
  { "<leader>fr", git_repos_picker, desc = "Open Git Repo Picker" },
  { "<leader>fs", function() smart_dirs.smart_cd() end, desc = "[S]mart directory navigation" },
  { "<leader>ff", function()
      require('telescope.builtin').find_files({
        no_ignore = true
      })
    end, desc = "[F]ind Files (Telescope)" },  -- Added mnemonic and description
  { "<leader>fa", function()
      require('telescope.builtin').find_files({
        follow = true,
        no_ignore = true,
        no_ignore_parent = true
      })
    end, desc = "[A]ll Files (Telescope)" },  -- Added mnemonic and description
  { "<leader>bn", ":bnext<CR>", desc = "[N]ext Buffer" }, -- Added mnemonic and description
  { "<leader>bp", ":bprevious<CR>", desc = "[P]revious Buffer" }, -- Added mnemonic and description
  { "<leader>bd", ":bdelete<CR>", desc = "[D]elete Buffer" }, -- Added mnemonic and description
  { "<leader>tc", ":lua set_terminal_cwd()<CR>", desc = "[T]erminal [C]WD" }, -- Added mnemonic and description
  { "<leader>zz", ':lua require("zotcite").open_attachment()<CR>', desc = "[Z]otcite [Z]otero Attachment" }, -- Added mnemonic and description
  { "<leader>qr", function()
      local file = vim.fn.expand("%")
      vim.cmd("!quarto render " .. file)
    end, desc = "render [Q]uarto File" }, -- Added mnemonic and description
    { "<leader>qq", function()  -- Changed to <leader>qp for preview to avoid conflict with <leader>qr
      local file = vim.fn.expand("%")
      vim.cmd("!quarto preview " .. file)
    end, desc = "[P]review Quarto File" }, -- Added mnemonic and description
}, { prefix = "<leader>", silent = true })

-- Load the module
local smart_dirs = require('misc.telescope_repos')

-- Create a command to call it
vim.api.nvim_create_user_command('S', function()
    smart_dirs.smart_cd()
end, {})

-- Optionally, add a keybinding
-- vim.keymap.set('n', '<leader>tr', function()
--     smart_dirs.smart_cd()
-- end, { desc = 'Smart directory navigation' })

-- git picker
local Path = require('plenary.path')
local scan = require('plenary.scandir')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local entry_display = require('telescope.pickers.entry_display')

-- Define the base directories to search
local git_repos_base = {
  "/Users/user/repos/",
  "/Users/user/repos/public",
  "/Users/user/repos/private",
  "/Users/user/.config/nvim/",
  "/Users/user/repos/private/",
  "/Users/user/repos/quartz/content"  -- This will now be checked as a potential git repo itself
}

-- Function to find all git repositories under the specified directories
local function find_git_repos(base_dirs)
  local repos = {}
  for _, dir in ipairs(base_dirs) do
    -- First check if the base directory itself is a git repo
    if Path:new(dir):joinpath(".git"):exists() then
      local repo_name = vim.fn.fnamemodify(dir, ":t")
      local parent_dir = vim.fn.fnamemodify(dir, ":h:t")
      table.insert(repos, {
        path = dir,
        name = repo_name,
        parent = parent_dir
      })
    end

    -- Then scan for subdirectories that are git repos
    local ok, files = pcall(scan.scan_dir, dir, {
      hidden = true,
      depth = 2,
      add_dirs = true,
      respect_gitignore = true
    })
    
    if ok then
      for _, file in ipairs(files) do
        if Path:new(file):joinpath(".git"):exists() then
          local repo_name = vim.fn.fnamemodify(file, ":t")
          local parent_dir = vim.fn.fnamemodify(file, ":h:t")
          table.insert(repos, {
            path = file,
            name = repo_name,
            parent = parent_dir
          })
        end
      end
    end
  end
  return repos
end

-- Create the telescope picker
local function git_repos_picker()
  -- Create displayer for custom formatting
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 30 },  -- repo name
      { width = 20 },  -- parent directory
      { remaining = true },  -- full path
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.name,
      entry.parent,
      { entry.path, "Comment" },
    })
  end

  -- Dynamically find git repositories
  local git_repos = find_git_repos(git_repos_base)

  pickers.new({}, {
    prompt_title = "Git Repositories",
    finder = finders.new_table({
      results = git_repos,
      entry_maker = function(entry)
        return {
          value = entry.path,
          name = entry.name,
          parent = entry.parent,
          path = entry.path,
          display = make_display,
          ordinal = entry.name .. " " .. entry.parent .. " " .. entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      -- Handle repository selection
      local function handle_repo_selection()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        -- Change the working directory
        vim.cmd("cd " .. vim.fn.fnameescape(selection.value))
        
        -- Change the editing session to the new directory
        vim.cmd("tcd " .. vim.fn.fnameescape(selection.value))
        
        -- Notify about the directory change
        vim.notify("Changed to repository: " .. selection.name, vim.log.levels.INFO)
      end

      -- Map enter in insert and normal mode
      map('i', '<CR>', handle_repo_selection)
      map('n', '<CR>', handle_repo_selection)
      
      return true
    end,
  }):find()
end

-- Set up the keymap
-- vim.keymap.set('n', '<leader>fr', git_repos_picker, {
--   desc = "Open Git Repo Picker",
--   silent = true
-- })

wk.add({
  { "<leader>fr", git_repos_picker, desc = "Open Git Repo Picker" },
  { "<leader>fs", function() smart_dirs.smart_cd() end, desc = "[S]mart directory navigation" },
}, { mode = 'n', silent = true })


wk.add {
        { "<leader>o", group = "Obsidian" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open note" },
        { "<leader>od", "<cmd>ObsidianDailies -10 0<cr>", desc = "Daily notes" },
        { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
        { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
        { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search" },
        { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Tags" },
        { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Links" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
        { "<leader>om", "<cmd>ObsidianTemplate<cr>", desc = "Template" },
        { "<leader>on", "<cmd>ObsidianQuickSwitch nav<cr>", desc = "Nav" },
        { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename" },
        { "<leader>oc", "<cmd>ObsidianTOC<cr>", desc = "Contents (TOC)" },
        {
          "<leader>ow",
          function()
            local Note = require "obsidian.note"
            ---@type obsidian.Client
            local client = require("obsidian").get_client()
            assert(client)

            local picker = client:picker()
            if not picker then
              client.log.err "No picker configured"
              return
            end

            ---@param dt number
            ---@return obsidian.Path
            local function weekly_note_path(dt)
              return client.dir / os.date("notes/weekly/week-of-%Y-%m-%d.md", dt)
            end

            ---@param dt number
            ---@return string
            local function weekly_alias(dt)
              local alias = os.date("Week of %A %B %d, %Y", dt)
              assert(type(alias) == "string")
              return alias
            end

            local day_of_week = os.date "%A"
            assert(type(day_of_week) == "string")

            ---@type integer
            local offset_start
            if day_of_week == "Sunday" then
              offset_start = 1
            elseif day_of_week == "Monday" then
              offset_start = 0
            elseif day_of_week == "Tuesday" then
              offset_start = -1
            elseif day_of_week == "Wednesday" then
              offset_start = -2
            elseif day_of_week == "Thursday" then
              offset_start = -3
            elseif day_of_week == "Friday" then
              offset_start = -4
            elseif day_of_week == "Saturday" then
              offset_start = 2
            end
            assert(offset_start)

            local current_week_dt = os.time() + (offset_start * 3600 * 24)
            ---@type obsidian.PickerEntry
            local weeklies = {}
            for week_offset = 1, -2, -1 do
              local week_dt = current_week_dt + (week_offset * 3600 * 24 * 7)
              local week_alias = weekly_alias(week_dt)
              local week_display = week_alias
              local path = weekly_note_path(week_dt)

              if week_offset == 0 then
                week_display = week_display .. " @current"
              elseif week_offset == 1 then
                week_display = week_display .. " @next"
              elseif week_offset == -1 then
                week_display = week_display .. " @last"
              end

              if not path:is_file() then
                week_display = week_display .. " ➡️ create"
              end

              weeklies[#weeklies + 1] = {
                value = week_dt,
                display = week_display,
                ordinal = week_display,
                filename = tostring(path),
              }
            end

            picker:pick(weeklies, {
              prompt_title = "Weeklies",
              callback = function(dt)
                local path = weekly_note_path(dt)
                ---@type obsidian.Note
                local note
                if path:is_file() then
                  note = Note.from_file(path)
                else
                  note = client:create_note {
                    id = path.name,
                    dir = path:parent(),
                    title = weekly_alias(dt),
                    tags = { "weekly-notes" },
                  }
                end
                client:open_note(note)
              end,
            })
          end,
          desc = "Weeklies",
        },
        {
          mode = { "v" },
          -- { "<leader>o", group = "Obsidian" },
          {
            "<leader>oe",
            function()
              local title = vim.fn.input { prompt = "Enter title (optional): " }
              vim.cmd("ObsidianExtractNote " .. title)
            end,
            desc = "Extract text into new note",
          },
          {
            "<leader>ol",
            function()
              vim.cmd "ObsidianLink"
            end,
            desc = "Link text to an existing note",
          },
          {
            "<leader>on",
            function()
              vim.cmd "ObsidianLinkNew"
            end,
            desc = "Link text to a new note",
          },
          {
            "<leader>ot",
            function()
              vim.cmd "ObsidianTags"
            end,
            desc = "Tags",
          },
        },
      }
