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

nmap('<leader>x', '<cmd>!chmod +x %<CR>')

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
-- local function send_cell()
--   if vim.b['quarto_is_r_mode'] == nil then
--     vim.fn['slime#send_cell']()
--     return
--   end
--   if vim.b['quarto_is_r_mode'] == true then
--     vim.g.slime_python_ipython = 0
--     local is_python = require('otter.tools.functions').is_otter_language_context 'python'
--     if is_python and not vim.b['reticulate_running'] then
--       vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
--       vim.b['reticulate_running'] = true
--     end
--     if not is_python and vim.b['reticulate_running'] then
--       vim.fn['slime#send']('exit' .. '\r')
--       vim.b['reticulate_running'] = false
--     end
--     vim.fn['slime#send_cell']()
--   end
-- end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
-- local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
-- slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
-- local function send_region()
--   -- if filetyps is not quarto, just send_region
--   if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
--     vim.cmd('normal' .. slime_send_region_cmd)
--     return
--   end
--   if vim.b['quarto_is_r_mode'] == true then
--     vim.g.slime_python_ipython = 0
--     local is_python = require('otter.tools.functions').is_otter_language_context 'python'
--     if is_python and not vim.b['reticulate_running'] then
--       vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
--       vim.b['reticulate_running'] = true
--     end
--     if not is_python and vim.b['reticulate_running'] then
--       vim.fn['slime#send']('exit' .. '\r')
--       vim.b['reticulate_running'] = false
--     end
--     vim.cmd('normal' .. slime_send_region_cmd)
--   end
-- end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
-- nmap('<c-cr>', send_cell)
-- nmap('<s-cr>', send_cell)
-- imap('<c-cr>', send_cell)
-- imap('<s-cr>', send_cell)

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
-- local function show_r_table()
--   local node = vim.treesitter.get_node { ignore_injections = false }
--   assert(node, 'no symbol found under cursor')
--   local text = vim.treesitter.get_node_text(node, 0)
--   local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
--   vim.cmd(cmd)
-- end

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

-- local is_code_chunk = function()
--   local current, _ = require('otter.keeper').get_current_language_context()
--   if current then
--     return true
--   else
--     return false
--   end
-- end

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
-- local insert_code_chunk = function(lang)
--   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
--   local keys
--   if is_code_chunk() then
--     keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
--   else
--     keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
--   end
--   keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
--   vim.api.nvim_feedkeys(keys, 'n', false)
-- end

-- local insert_r_chunk = function()
--   insert_code_chunk 'r'
-- end
--
-- local insert_py_chunk = function()
--   insert_code_chunk 'python'
-- end
--
-- local insert_lua_chunk = function()
--   insert_code_chunk 'lua'
-- end
--
-- local insert_julia_chunk = function()
--   insert_code_chunk 'julia'
-- end
--
-- local insert_bash_chunk = function()
--   insert_code_chunk 'bash'
-- end
--
-- local insert_ojs_chunk = function()
--   insert_code_chunk 'ojs'
-- end

--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
  { '<c-LeftMouse>', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = 'go to definition' },
  { '<c-q>', '<cmd>q<cr>', desc = 'close buffer' },
  { '<cm-i>', insert_py_chunk, desc = 'python code chunk' },
  { '<esc>', '<cmd>noh<cr>', desc = 'remove search highlight' },
  -- { '<m-I>', insert_py_chunk, desc = 'python code chunk' },
  -- { "<leader>d", insert_r_chunk, desc = "r code chunk" },
  { '[q', ':silent cprev<cr>', desc = '[q]uickfix prev' },
  { ']q', ':silent cnext<cr>', desc = '[q]uickfix next' },
  { 'gN', 'Nzzzv', desc = 'center search' },
  { 'gf', ':e <cfile><CR>', desc = 'edit file' },
  { 'gl', '<c-]>', desc = 'open help link' },
  { 'n', 'nzzzv', desc = 'center search' },
  { 'z?', ':setlocal spell!<cr>', desc = 'toggle [z]pellcheck' },
  { 'zl', ':Telescope spell_suggest<cr>', desc = '[l]ist spelling suggestions' },
}, { mode = 'n', silent = true })

-- visual mode
wk.add {
  {
    mode = { 'v' },
    { '.', ':norm .<cr>', desc = 'repat last normal mode command' },
    { '<M-j>', ":m'>+<cr>`<my`>mzgv`yo`z", desc = 'move line down' },
    { '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z", desc = 'move line up' },
    { '<cr>', send_region, desc = 'run code region' },
    { 'q', ':norm @q<cr>', desc = 'repat q macro' },
  },
}

-- visual with <leader>
wk.add({
  -- { "<leader>d", '"_d', desc = "delete without overwriting reg", mode = "v" },
  -- { "<leader>p", '"_dP', desc = "replace without overwriting reg", mode = "v" },
}, { mode = 'v' })

-- insert mode
wk.add({
  {
    mode = { 'i' },
    { '<c-x><c-x>', '<c-x><c-o>', desc = 'omnifunc completion' },
    -- { '<cm-i>', insert_py_chunk, desc = 'python code chunk' },
    { '<m-->', ' <- ', desc = 'assign' },
    -- { '<m-I>', insert_py_chunk, desc = 'python code chunk' },
    -- { '<m-i>', insert_r_chunk, desc = 'r code chunk' },
    { '<m-m>', ' |>', desc = 'pipe' },
  },
}, { mode = 'i' })

-- local function new_terminal(lang)
--   vim.cmd('vsplit term://' .. lang)
-- end
--
-- local function new_terminal_python()
--   new_terminal 'python'
-- end
--
-- local function new_terminal_r()
--   new_terminal 'R --no-save'
-- end
--
-- local function new_terminal_ipython()
--   new_terminal 'ipython --no-confirm-exit'
-- end
--
-- local function new_terminal_julia()
--   new_terminal 'julia'
-- end
--
-- local function new_terminal_shell()
--   new_terminal '$SHELL'
-- end
--
-- local function get_otter_symbols_lang()
--   local otterkeeper = require 'otter.keeper'
--   local main_nr = vim.api.nvim_get_current_buf()
--   local langs = {}
--   for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
--     langs[i] = i .. ': ' .. l
--   end
--   -- promt to choose one of langs
--   local i = vim.fn.inputlist(langs)
--   local lang = otterkeeper.rafts[main_nr].languages[i]
--   local params = {
--     textDocument = vim.lsp.util.make_text_document_params(),
--     otter = {
--       lang = lang,
--     },
--   }
--   -- don't pass a handler, as we want otter to use it's own handlers
--   vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
-- end

-- vim.keymap.set("n", "<leader>os", get_otter_symbols_lang, {desc = "otter [s]ymbols"})

-- local anki = require('utils.anki')
-- In your keymaps file

-- normal mode with <leader>
wk.add({
  {
    { '<leader>p', group = '[P]andoc' },
    { '<leader>pw', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx'<CR>", desc = '[w]ord' },
    { '<leader>pm', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.md'<CR>", desc = '[m]arkdown' },
    { '<leader>ph', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.html'<CR>", desc = '[h]tml' },
    { '<leader>pl', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.tex'<CR>", desc = '[l]atex' },
    { '<leader>pp', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.pdf' open=0<CR>", desc = '[p]df' },
    { '<leader>pv', "<cmd>TermExec cmd='zathura %:p:r.pdf &' open=0<CR>", desc = '[v]iew' },
    { '<leader>ps', "<cmd>TermExec cmd='python3 /Users/user/repos/scripts/splitter.py %:p:r.md %:p:r.md'<CR>", desc = '[s]plit sentences' },
    { '<leader>pu', "<cmd>TermExec cmd='python3 /Users/user/repos/scripts/unwrapper.py %:p:r.md %:p:r.md'<CR>", desc = '[u]nwrap sentences' },
    { '<leader>pi', "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx --resource-path=%:p:h'<CR>", desc = 'convert to docx with [i]mages' },
    -- {
    --   '<leader>pb',
    --   "<cmd>TermExec cmd='source /Users/user/venv/bin/activate.fish && pandoc /Users/user/repos/quartz/content/projects/EYEGEN/notes/clinical-care-overview.md -s -o /Users/user/repos/quartz/content/projects/EYEGEN/notes/clinical-care-overview.docx --citeproc --bibliography=/Users/user/repos/quartz/content/projects/EYEGEN/notes/references.bib'<CR>",
    --   desc = 'convert with .[b]ib file',
    -- },
  {
  '<leader>pb',
  function()
    local file = vim.fn.expand('%:p')
    local output = vim.fn.expand('%:p:r') .. '.docx'
    local bibfile = vim.fn.fnamemodify(file, ':h') .. '/references.bib'
    vim.cmd("TermExec cmd='pandoc " .. file .. " -s -o " .. output .. " --citeproc --bibliography=" .. bibfile .. "'")
  end,
  desc = 'convert with .[b]ib file',
},
    {
      '<leader>pz',
      "<cmd>TermExec cmd='source /Users/user/venv/bin/activate.fish && "
        .. "pandoc %:p -s -o %:p:r.docx -F /Users/user/repos/public/zotcite/python3/zotref.py --citep'<CR>",
      desc = '[z]otcite export',
    },
    { '<leader>m', group = 'Markdown' },
    { '<leader>mt', '<cmd>MarkdownPreviewToggle<cr>', desc = '[T]oggle Preview' },
    { '<leader>mp', '<cmd>MarkdownPreview<cr>', desc = 'Start [P]review' },
    { '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', desc = '[S]top Preview' },
    { '<leader>a', group = 'anki' },
    -- { "<leader>ac", anki.create_notes(), desc = "[C]reate Notes" },
    -- { "<leader>ap", anki.paste_image_to_anki(), desc = "[P]aste image" },
    -- { "<leader>aa", anki.run_apy_add_from_file(), desc = "[A]dd notes" },
    -- { '<leader><cr>', send_cell, desc = 'run code cell' },
    { '<leader>c', group = '[c]ode / [c]ell / [c]hunk' },
    {
      '<leader>cu',
      function()
        local file_path = vim.fn.expand '%:p'
        local file_dir = vim.fn.expand '%:p:h'
        vim.notify('Current file (absolute): ' .. file_path, vim.log.levels.INFO)
        vim.notify('Current directory (absolute): ' .. file_dir, vim.log.levels.INFO)
      end,
      desc = 'Print [C]urrent [F]ile/Buffer Directory (Absolute)',
    },
    -- { "<leader>ci", new_terminal_ipython, desc = "new [i]python terminal" },
    -- { "<leader>cj", new_terminal_julia, desc = "new [j]ulia terminal" },
    -- { "<leader>cn", new_terminal_shell, desc = "[n]ew terminal with shell" },
    -- { "<leader>cp", new_terminal_python, desc = "new [p]ython terminal" },
    -- { "<leader>cr", new_terminal_r, desc = "new [R] terminal" },
    -- { "<leader>d", group = "[d]ebug" },
    -- { "<leader>dt", group = "[t]est" },
    { '<leader>e', group = '[e]dit' },
    { '<leader>f', group = '[f]ind (telescope)' },
    { '<leader>f<space>', '<cmd>Telescope buffers<cr>', desc = '[ ] buffers' },
    { '<leader>fM', '<cmd>Telescope man_pages<cr>', desc = '[M]an pages' },
    { '<leader>fb', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = '[b]uffer fuzzy find' },
    { '<leader>fc', '<cmd>Telescope git_commits<cr>', desc = 'git [c]ommits' },
    { '<leader>fd', '<cmd>Telescope buffers<cr>', desc = '[d] buffers' },
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = '[f]iles' },
    { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = '[g]rep' },
    { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = '[h]elp' },
    { '<leader>fj', '<cmd>Telescope jumplist<cr>', desc = '[j]umplist' },
    { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = '[k]eymaps' },
    { '<leader>fl', '<cmd>Telescope loclist<cr>', desc = '[l]oclist' },
    { '<leader>fm', '<cmd>Telescope marks<cr>', desc = '[m]arks' },
    { '<leader>fq', '<cmd>Telescope quickfix<cr>', desc = '[q]uickfix' },
    { '<leader>g', group = '[g]it' },
    { '<leader>gb', group = '[b]lame' },
    { '<leader>gbb', ':GitBlameToggle<cr>', desc = '[b]lame toggle virtual text' },
    { '<leader>gbc', ':GitBlameCopyCommitURL<cr>', desc = '[c]opy' },
    { '<leader>gbo', ':GitBlameOpenCommitURL<cr>', desc = '[o]pen' },
    { '<leader>gc', ':GitConflictRefresh<cr>', desc = '[c]onflict' },
    { '<leader>gd', group = '[d]iff' },
    { '<leader>gdc', ':DiffviewClose<cr>', desc = '[c]lose' },
    { '<leader>gdo', ':DiffviewOpen<cr>', desc = '[o]pen' },
    { '<leader>gs', ':Gitsigns<cr>', desc = 'git [s]igns' },
    { '<leader>gwc', ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", desc = 'worktree create' },
    { '<leader>gws', ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", desc = 'worktree switch' },
    { '<leader>h', group = '[h]elp / [h]ide / debug' },
    { '<leader>hc', group = '[c]onceal' },
    { '<leader>hch', ':set conceallevel=1<cr>', desc = '[h]ide/conceal' },
    { '<leader>hcs', ':set conceallevel=0<cr>', desc = '[s]how/unconceal' },
    { '<leader>ht', group = '[t]reesitter' },
    { '<leader>htt', vim.treesitter.inspect_tree, desc = 'show [t]ree' },
    { '<leader>i', group = '[i]mage' },
    { '<leader>l', group = '[l]anguage/lsp' },
    { '<leader>la', vim.lsp.buf.code_action, desc = 'code [a]ction' },
    { '<leader>ld', group = '[d]iagnostics' },
    {
      '<leader>ldd',
      function()
        vim.diagnostic.enable(false)
      end,
      desc = '[d]isable',
    },
    { '<leader>lde', vim.diagnostic.enable, desc = '[e]nable' },
    { '<leader>le', vim.diagnostic.open_float, desc = 'diagnostics (show hover [e]rror)' },
    { '<leader>lg', ':Neogen<cr>', desc = 'neo[g]en docstring' },
    { '<leader>o', group = '[o]tter & c[o]de' },
    -- { "<leader>oa", require'otter'.activate, desc = "otter [a]ctivate" },
    -- { "<leader>ob", insert_bash_chunk, desc = "[b]ash code chunk" },
    -- { "<leader>oc", "O# %%<cr>", desc = "magic [c]omment code chunk # %%" },
    -- { "<leader>od", require'otter'.activate, desc = "otter [d]eactivate" },
    -- { "<leader>oj", insert_julia_chunk, desc = "[j]ulia code chunk" },
    -- { "<leader>ol", insert_lua_chunk, desc = "[l]lua code chunk" },
    -- { "<leader>oo", insert_ojs_chunk, desc = "[o]bservable js code chunk" },
    -- { "<leader>op", insert_py_chunk, desc = "[p]ython code chunk" },
    -- { "<leader>or", insert_r_chunk, desc = "[r] code chunk" },
    { '<leader>o', group = 'Obsidian' },
    { '<leader>oo', '<cmd>ObsidianOpen<cr>', desc = 'Open note' },
    { '<leader>od', '<cmd>ObsidianDailies -10 0<cr>', desc = 'Daily notes' },
    { '<leader>op', '<cmd>ObsidianPasteImg<cr>', desc = 'Paste image' },
    { '<leader>oq', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Quick switch' },
    { '<leader>os', '<cmd>ObsidianSearch<cr>', desc = 'Search' },
    { '<leader>ot', '<cmd>ObsidianTags<cr>', desc = 'Tags' },
    { '<leader>ol', '<cmd>ObsidianLinks<cr>', desc = 'Links' },
    { '<leader>ob', '<cmd>ObsidianBacklinks<cr>', desc = 'Backlinks' },
    { '<leader>om', '<cmd>ObsidianTemplate<cr>', desc = 'Template' },
    { '<leader>on', '<cmd>ObsidianQuickSwitch nav<cr>', desc = 'Nav' },
    { '<leader>or', '<cmd>ObsidianRename<cr>', desc = 'Rename' },
    { '<leader>oc', '<cmd>ObsidianTOC<cr>', desc = 'Contents (TOC)' },
    {
      '<leader>ow',
      function()
        local Note = require 'obsidian.note'
        ---@type obsidian.Client
        local client = require('obsidian').get_client()
        assert(client)
        local picker = client:picker()
        if not picker then
          client.log.err 'No picker configured'
          return
        end
        ---@param dt number
        ---@return obsidian.Path
        local function weekly_note_path(dt)
          return client.dir / os.date('06-temporal/weekly/week-of-%Y-%m-%d.md', dt)
        end
        ---@param dt number
        ---@return string
        local function weekly_alias(dt)
          local alias = os.date('Week of %A %B %d, %Y', dt)
          assert(type(alias) == 'string')
          return alias
        end
        local day_of_week = os.date '%A'
        assert(type(day_of_week) == 'string')
        ---@type integer
        local offset_start
        if day_of_week == 'Sunday' then
          offset_start = 1
        elseif day_of_week == 'Monday' then
          offset_start = 0
        elseif day_of_week == 'Tuesday' then
          offset_start = -1
        elseif day_of_week == 'Wednesday' then
          offset_start = -2
        elseif day_of_week == 'Thursday' then
          offset_start = -3
        elseif day_of_week == 'Friday' then
          offset_start = -4
        elseif day_of_week == 'Saturday' then
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
            week_display = week_display .. ' @current'
          elseif week_offset == 1 then
            week_display = week_display .. ' @next'
          elseif week_offset == -1 then
            week_display = week_display .. ' @last'
          end
          if not path:is_file() then
            week_display = week_display .. ' ➡️ create'
          end
          weeklies[#weeklies + 1] = {
            value = week_dt,
            display = week_display,
            ordinal = week_display,
            filename = tostring(path),
          }
        end

        -- Define the template with explicit double line breaks between sections
        local template = [[
## Progress Review (25 minutes)
- Assess completion status of each project milestone
- Document specific achievements and blockers
- Calculate time spent on each major category of work
- Note any patterns in productivity or challenges


## Next Week Planning (25 minutes)
- Set 1-3 primary objectives for each project
- Identify specific textbook sections/papers to study
- Pre-schedule any flexible meetings or collaborations
- Map deadlines and create buffer time for unforeseen issues


## Reflection & Adjustment (10 minutes)
- Review your productivity metrics
- Adjust time allocations based on progress
- Note any schedule modifications needed
- Document lessons learned
]]

        -- This function will insert the template into the note
        local function insert_weekly_template(note)
          -- Only insert template if the note is new or doesn't already have the template
          if note and note.content and not note.content:find '## Progress Review' then
            -- If the note has content, add a newline separator
            if #note.content > 0 and not note.content:match '\n$' then
              note.content = note.content .. '\n\n'
            end

            note.content = note.content .. template
            note:save()
          end

          return note
        end

        picker:pick(weeklies, {
          prompt_title = 'Weeklies',
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
                tags = { 'weekly-notes' },
              }
              -- For new notes, insert the template right away
              note = insert_weekly_template(note)
            end

            -- Open the note whether it's new or existing
            client:open_note(note)

            -- For existing notes, check if we need to add the template
            -- This will run after opening the note
            if path:is_file() then
              vim.defer_fn(function()
                -- Wait a bit for the buffer to load
                local bufnr = vim.api.nvim_get_current_buf()
                local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

                -- Check if template is already in the buffer
                if not content:find '## Progress Review' then
                  -- Split the template into lines, preserving empty lines
                  local lines = {}
                  for line in (template .. '\n'):gmatch '([^\n]*)\n' do
                    table.insert(lines, line)
                  end

                  -- Add newlines if needed
                  local last_line = vim.api.nvim_buf_line_count(bufnr)
                  local last_line_content = vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, false)[1]
                  if last_line_content and #last_line_content > 0 then
                    vim.api.nvim_buf_set_lines(bufnr, last_line, last_line, false, { '', '' })
                    last_line = last_line + 2
                  end

                  -- Insert template at end
                  vim.api.nvim_buf_set_lines(bufnr, last_line, last_line, false, lines)

                  -- Save the buffer
                  vim.cmd 'w'
                end
              end, 100) -- 100ms delay to ensure buffer is loaded
            end
          end,
        })
      end,
      desc = 'Weeklies with Template',
    },
    {
      mode = { 'v' },
      -- { "<leader>o", group = "Obsidian" },
      {
        '<leader>oe',
        function()
          local title = vim.fn.input { prompt = 'Enter title (optional): ' }
          vim.cmd('ObsidianExtractNote ' .. title)
        end,
        desc = 'Extract text into new note',
      },
      {
        '<leader>ol',
        function()
          vim.cmd 'ObsidianLink'
        end,
        desc = 'Link text to an existing note',
      },
      {
        '<leader>on',
        function()
          vim.cmd 'ObsidianLinkNew'
        end,
        desc = 'Link text to a new note',
      },
      {
        '<leader>ot',
        function()
          vim.cmd 'ObsidianTags'
        end,
        desc = 'Tags',
      },
    },
    { '<leader>q', group = '[q]uarto + [q]uartz' },
    {
      '<leader>qq',
      function()
        local file = vim.fn.expand '%'
        vim.cmd('!quarto render ' .. file)
      end,
      desc = 'render [Q]uarto File',
    }, -- Added mnemonic and description
    -- { "<leader>qq", function()  -- Changed to <leader>qp for preview to avoid conflict with <leader>qr
    --   local file = vim.fn.expand("%")
    --   vim.cmd("!quarto preview " .. file)
    -- end, desc = "Preview [Q]uarto File" }, -- Added mnemonic and description
    -- {
    --   '<leader>qE',
    --   function()
    --     require('otter').export(true)
    --   end,
    --   desc = '[E]xport with overwrite',
    -- },
    { '<leader>qa', ':QuartoActivate<cr>', desc = '[a]ctivate' },
    -- { '<leader>qe', require('otter').export, desc = '[e]xport' },
    { '<leader>qh', ':QuartoHelp ', desc = '[h]elp' },
    -- { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review" },
    { '<leader>qc', ":lua require'quarto'.quartoClosePreview()<cr>", desc = '[q]uiet preview' },
    { '<leader>qr', group = '[r]un' },
    { '<leader>qra', ':QuartoSendAll<cr>', desc = 'run [a]ll' },
    { '<leader>qrb', ':QuartoSendBelow<cr>', desc = 'run [b]elow' },
    { '<leader>qrr', ':QuartoSendAbove<cr>', desc = 'to cu[r]sor' },
    { '<leader>r', group = '[r] R specific tools' },
    -- { "<leader>rt", show_r_table, desc = "show [t]able" },
    { '<leader>v', group = '[v]im' },
    { '<leader>vc', ':Telescope colorscheme<cr>', desc = '[c]olortheme' },
    { '<leader>vh', ':execute "h " . expand("<cword>")<cr>', desc = 'vim [h]elp for current word' },
    { '<leader>vl', ':Lazy<cr>', desc = '[l]azy package manager' },
    { '<leader>vm', ':Mason<cr>', desc = '[m]ason software installer' },
    { '<leader>vs', ':e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>', desc = '[s]ettings, edit vimrc' },
    { '<leader>vt', toggle_light_dark_theme, desc = '[t]oggle light/dark theme' },
    { '<leader>x', group = 'e[x]ecute' },
    -- { "<leader>xx", ":w<cr>:source %<cr>", desc = "[x] source %" },
  },
}, { mode = 'n' })

-- vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })
-- unbind ctrl-k in normal mode
vim.api.nvim_set_keymap('i', '<C-k>', '<nop>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'zz', ':Alpha<CR>', { noremap = true, silent = true })
--
local smart_dirs = require 'misc.telescope_repos'

-- Create a command to call it
vim.api.nvim_create_user_command('S', function()
  smart_dirs.smart_cd()
end, {})
wk.add({
  {
    '<leader>fs',
    function()
      smart_dirs.smart_cd()
    end,
    desc = '[S]mart directory navigation',
  },
}, { mode = 'n', silent = true })

wk.add({
  {
    '<leader>an',
    function()
      local file = vim.fn.expand '%:p' -- Get the absolute path of the current file
      local cmd = string.format('/Users/user/repos/scripts/apy-update.py -u %s', vim.fn.shellescape(file))
      vim.cmd('!' .. cmd)
    end,
    desc = 'Run apy-update.py on current file',
  },
}, { mode = 'n', silent = true })

require 'config.quartz_terminals'

function ToggleObsidianFrontmatter()
  -- Get the current client instance
  local obsidian = require 'obsidian'
  local client = obsidian.get_client()

  if not client then
    vim.notify('No active Obsidian client found', vim.log.levels.ERROR)
    return
  end

  -- Get the current configuration
  local current_config = client.opts

  -- Toggle the disable_frontmatter option
  current_config.disable_frontmatter = not current_config.disable_frontmatter

  -- Re-setup with the modified config
  obsidian.setup(current_config)

  -- Notify the user
  local state = current_config.disable_frontmatter and 'disabled' or 'enabled'
  vim.notify('Obsidian frontmatter management ' .. state, vim.log.levels.INFO)
end

-- Add a keybinding
vim.api.nvim_set_keymap(
  'n',
  '<leader>of',
  [[<cmd>lua ToggleObsidianFrontmatter()<CR>]],
  { noremap = true, silent = true, desc = 'Toggle Obsidian frontmatter' }
)

-- set keybinds for both INSERT and VISUAL.
vim.api.nvim_set_keymap('i', '<C-n>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('s', '<C-n>', '<Plug>luasnip-next-choice', {})
vim.api.nvim_set_keymap('i', '<C-p>', '<Plug>luasnip-prev-choice', {})
vim.api.nvim_set_keymap('s', '<C-p>', '<Plug>luasnip-prev-choice', {})

