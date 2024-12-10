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

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
  -- if filetyps is not quarto, just send_region
  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    vim.cmd('normal' .. slime_send_region_cmd)
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.cmd('normal' .. slime_send_region_cmd)
  end
end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap('<c-cr>', send_cell)
nmap('<s-cr>', send_cell)
imap('<c-cr>', send_cell)
imap('<s-cr>', send_cell)

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
local function show_r_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  assert(node, 'no symbol found under cursor')
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

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

local is_code_chunk = function()
  local current, _ = require('otter.keeper').get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local insert_r_chunk = function()
  insert_code_chunk 'r'
end

local insert_py_chunk = function()
  insert_code_chunk 'python'
end

local insert_lua_chunk = function()
  insert_code_chunk 'lua'
end

local insert_julia_chunk = function()
  insert_code_chunk 'julia'
end

local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end

local insert_ojs_chunk = function()
  insert_code_chunk 'ojs'
end

--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
    { "<c-LeftMouse>", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "go to definition" },
    { "<c-q>", "<cmd>q<cr>", desc = "close buffer" },
    { "<cm-i>", insert_py_chunk, desc = "python code chunk" },
    { "<esc>", "<cmd>noh<cr>", desc = "remove search highlight" },
    { "<m-I>", insert_py_chunk, desc = "python code chunk" },
    { "<m-i>", insert_r_chunk, desc = "r code chunk" },
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
      { "<cr>", send_region, desc = "run code region" },
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
      { "<cm-i>", insert_py_chunk, desc = "python code chunk" },
      { "<m-->", " <- ", desc = "assign" },
      { "<m-I>", insert_py_chunk, desc = "python code chunk" },
      { "<m-i>", insert_r_chunk, desc = "r code chunk" },
      { "<m-m>", " |>", desc = "pipe" },
    },
}, { mode = 'i' })

local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end

local function new_terminal_python()
  new_terminal 'python'
end

local function new_terminal_r()
  new_terminal 'R --no-save'
end

local function new_terminal_ipython()
  new_terminal 'ipython --no-confirm-exit'
end

local function new_terminal_julia()
  new_terminal 'julia'
end

local function new_terminal_shell()
  new_terminal '$SHELL'
end

local function get_otter_symbols_lang()
  local otterkeeper = require'otter.keeper'
  local main_nr = vim.api.nvim_get_current_buf()
  local langs = {}
  for i,l in ipairs(otterkeeper.rafts[main_nr].languages) do
    langs[i] = i .. ': ' .. l
  end
  -- promt to choose one of langs
  local i = vim.fn.inputlist(langs)
  local lang = otterkeeper.rafts[main_nr].languages[i]
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    otter = {
      lang = lang
    }
  }
  -- don't pass a handler, as we want otter to use it's own handlers
  vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
end

vim.keymap.set("n", "<leader>os", get_otter_symbols_lang, {desc = "otter [s]ymbols"})


-- normal mode with <leader>
wk.add({
  {
    { "<leader><cr>", send_cell, desc = "run code cell" },
    { "<leader>c", group = "[c]ode / [c]ell / [c]hunk" },
    { "<leader>ci", new_terminal_ipython, desc = "new [i]python terminal" },
    { "<leader>cj", new_terminal_julia, desc = "new [j]ulia terminal" },
    { "<leader>cn", new_terminal_shell, desc = "[n]ew terminal with shell" },
    { "<leader>cp", new_terminal_python, desc = "new [p]ython terminal" },
    { "<leader>cr", new_terminal_r, desc = "new [R] terminal" },
    { "<leader>d", group = "[d]ebug" },
    { "<leader>dt", group = "[t]est" },
    { "<leader>e", group = "[e]dit" },
    { "<leader>f", group = "[f]ind (telescope)" },
    { "<leader>f<space>", "<cmd>Telescope buffers<cr>", desc = "[ ] buffers" },
    { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "[M]an pages" },
    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[b]uffer fuzzy find" },
    { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "git [c]ommits" },
    { "<leader>fd", "<cmd>Telescope buffers<cr>", desc = "[d] buffers" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[f]iles" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "[g]rep" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "[h]elp" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "[j]umplist" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "[k]eymaps" },
    { "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "[l]oclist" },
    { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "[m]arks" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "[q]uickfix" },
    { "<leader>g", group = "[g]it" },
    { "<leader>gb", group = "[b]lame" },
    { "<leader>gbb", ":GitBlameToggle<cr>", desc = "[b]lame toggle virtual text" },
    { "<leader>gbc", ":GitBlameCopyCommitURL<cr>", desc = "[c]opy" },
    { "<leader>gbo", ":GitBlameOpenCommitURL<cr>", desc = "[o]pen" },
    { "<leader>gc", ":GitConflictRefresh<cr>", desc = "[c]onflict" },
    { "<leader>gd", group = "[d]iff" },
    { "<leader>gdc", ":DiffviewClose<cr>", desc = "[c]lose" },
    { "<leader>gdo", ":DiffviewOpen<cr>", desc = "[o]pen" },
    { "<leader>gs", ":Gitsigns<cr>", desc = "git [s]igns" },
    { "<leader>gwc", ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", desc = "worktree create" },
    { "<leader>gws", ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", desc = "worktree switch" },
    { "<leader>h", group = "[h]elp / [h]ide / debug" },
    { "<leader>hc", group = "[c]onceal" },
    { "<leader>hch", ":set conceallevel=1<cr>", desc = "[h]ide/conceal" },
    { "<leader>hcs", ":set conceallevel=0<cr>", desc = "[s]how/unconceal" },
    { "<leader>ht", group = "[t]reesitter" },
    { "<leader>htt", vim.treesitter.inspect_tree, desc = "show [t]ree" },
    { "<leader>i", group = "[i]mage" },
    { "<leader>l", group = "[l]anguage/lsp" },
    { "<leader>la", vim.lsp.buf.code_action, desc = "code [a]ction" },
    { "<leader>ld", group = "[d]iagnostics" },
    { "<leader>ldd", function() vim.diagnostic.enable(false) end, desc = "[d]isable" },
    { "<leader>lde", vim.diagnostic.enable, desc = "[e]nable" },
    { "<leader>le", vim.diagnostic.open_float, desc = "diagnostics (show hover [e]rror)" },
    { "<leader>lg", ":Neogen<cr>", desc = "neo[g]en docstring" },
    { "<leader>o", group = "[o]tter & c[o]de" },
    { "<leader>oa", require'otter'.activate, desc = "otter [a]ctivate" },
    { "<leader>ob", insert_bash_chunk, desc = "[b]ash code chunk" },
    { "<leader>oc", "O# %%<cr>", desc = "magic [c]omment code chunk # %%" },
    { "<leader>od", require'otter'.activate, desc = "otter [d]eactivate" },
    { "<leader>oj", insert_julia_chunk, desc = "[j]ulia code chunk" },
    { "<leader>ol", insert_lua_chunk, desc = "[l]lua code chunk" },
    { "<leader>oo", insert_ojs_chunk, desc = "[o]bservable js code chunk" },
    { "<leader>op", insert_py_chunk, desc = "[p]ython code chunk" },
    { "<leader>or", insert_r_chunk, desc = "[r] code chunk" },
    { "<leader>q", group = "[q]uarto" },
    { "<leader>qE", function() require('otter').export(true) end, desc = "[E]xport with overwrite" },
    { "<leader>qa", ":QuartoActivate<cr>", desc = "[a]ctivate" },
    { "<leader>qe", require('otter').export, desc = "[e]xport" },
    { "<leader>qh", ":QuartoHelp ", desc = "[h]elp" },
    { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review" },
    { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uiet preview" },
    { "<leader>qr", group = "[r]un" },
    { "<leader>qra", ":QuartoSendAll<cr>", desc = "run [a]ll" },
    { "<leader>qrb", ":QuartoSendBelow<cr>", desc = "run [b]elow" },
    { "<leader>qrr", ":QuartoSendAbove<cr>", desc = "to cu[r]sor" },
    { "<leader>r", group = "[r] R specific tools" },
    { "<leader>rt", show_r_table, desc = "show [t]able" },
    { "<leader>v", group = "[v]im" },
    { "<leader>vc", ":Telescope colorscheme<cr>", desc = "[c]olortheme" },
    { "<leader>vh", ':execute "h " . expand("<cword>")<cr>', desc = "vim [h]elp for current word" },
    { "<leader>vl", ":Lazy<cr>", desc = "[l]azy package manager" },
    { "<leader>vm", ":Mason<cr>", desc = "[m]ason software installer" },
    { "<leader>vs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>", desc = "[s]ettings, edit vimrc" },
    { "<leader>vt", toggle_light_dark_theme, desc = "[t]oggle light/dark theme" },
    { "<leader>x", group = "e[x]ecute" },
    { "<leader>xx", ":w<cr>:source %<cr>", desc = "[x] source %" },
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
    "<leader>pi", "<cmd>TermExec cmd='source ~/.config/nvim/venv/bin/activate.fish && " ..
      "pandoc %:p -t markdown --wrap=none -o %:p:r.md && " ..
      "sentence-splitter %:p:r.md %:p:r_split.md'<CR>", 
      desc = "[i]mport docx + split"
  },
  {
    "<leader>pz", "<cmd>TermExec cmd='source ~/.config/nvim/venv/bin/activate.fish && " ..
      "pandoc %:p -s -o %:p:r.docx -F ~/.local/share/nvim-text/lazy/zotcite/python3/zotref.py --citep'<CR>", 
      desc = "[z]otcite export"
  },
{
  "<leader>pv", ":terminal source ~/.config/nvim/venv/bin/activate.fish && " ..
    "pandoc %:p -s -o %:p:r.docx -F ~/.local/share/nvim-text/lazy/zotcite/python3/zotref.py --citep --csl /Users/user/Downloads/vancouver.csl<CR>",
  desc = "[v]ancouver export"
}
,
}, { mode = 'n' })

local map = vim.keymap.set
map("n", "<leader>fo", function()
    require('telescope.builtin').oldfiles({
        no_ignore = true
        -- hidden = true
    })
end, { desc = "telescope find all oldfiles (including ignored)" })

-- For regular find_files, you can create a similar function with more options
map("n", "<leader>ff", function()
    require('telescope.builtin').find_files({
        -- Default behavior, but you can add more options if needed
        no_ignore = true
        -- hidden = true
    })
end, { desc = "telescope find files" })

-- Your existing all files mapping remains the same
map("n", "<leader>fa", function()
    require('telescope.builtin').find_files({
        follow = true,
        no_ignore = true,
        -- hidden = true,
        no_ignore_parent = true
    })
end, { desc = "telescope find all files (including ignored)" })

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
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.docx",
    callback = function()
        vim.fn.jobstart({"open", "-a", "Microsoft Word", vim.fn.expand("%:p")})
        vim.cmd("bd!") -- Close the buffer after opening externally
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

local function autoCapitalizeMd()
    -- Get current buffer and cursor position
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    col = col + 1 -- Adjust for Lua's 1-based indexing
    local line = vim.api.nvim_get_current_line()
    local char = vim.v.char

    -- Function to check if a line is the front matter delimiter
    local function is_frontmatter_delimiter(text)
        return text:match("^%-%-%-%s*$") ~= nil
    end

    -- Determine if the current position is within YAML front matter
    local is_in_frontmatter = false
    if is_frontmatter_delimiter(line) then
        if row == 1 then
            is_in_frontmatter = true
        else
            -- Check if we have already passed the front matter
            local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
            if is_frontmatter_delimiter(first_line) then
                local found_end = false
                for i = 2, row - 1 do
                    local check_line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
                    if is_frontmatter_delimiter(check_line) then
                        found_end = true
                        break
                    end
                end
                is_in_frontmatter = not found_end
            end
        end
    end

    -- Do not auto-capitalize if inside front matter
    if is_in_frontmatter then
        return
    end

    -- Refine the early return to block only YAML-specific indicators,
    -- allowing markdown list items that start with '- '
    if line:match("^%s*[:-]") then
        -- Block lines that start with ':' (common in YAML) but allow '-' followed by space
        if not line:match("^%s*%-%s") then
            return
        end
    end

    -- Regular auto-capitalization logic
    if col == 1 then
        -- Capitalize first character of the line
        vim.v.char = char:upper()
    else
        local prev_chars_up_to_col = line:sub(1, col - 1)

        -- Trim trailing spaces for accurate pattern matching
        local trimmed = prev_chars_up_to_col:match("^(.-)%s*$")

        -- Capitalize after sentence enders (., !, ?) followed by space
        if trimmed:match("[%.!?]$") then
            vim.v.char = char:upper()
        -- Capitalize after '#' (heading markers) if at the start of the line
        elseif trimmed:match("^#+%s*$") then
            vim.v.char = char:upper()
        -- Capitalize after '-' (markdown list items) with optional indentation
        elseif trimmed:match("^%s*%-%s*$") then
            vim.v.char = char:upper()
        end
    end
end

-- Register the function globally if needed
_G.autoCapitalizeMd = autoCapitalizeMd

-- Setup autocommand using vim.cmd for Markdown filetypes
vim.cmd [[
  augroup AutoCapitalizeMd
    autocmd!
    autocmd InsertCharPre *.md lua _G.autoCapitalizeMd()
  augroup END
]]

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

vim.api.nvim_set_keymap('n', '<c-x>', ':lua set_terminal_cwd()<CR>', {noremap = true, silent = true})

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

vim.api.nvim_set_keymap("n", "<C-r>", "<cmd>redo<CR>", { noremap = true, silent = true })

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


