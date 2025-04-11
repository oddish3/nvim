local api = vim.api
local ts = vim.treesitter

vim.b.slime_cell_delimiter = '```'
vim.b['quarto_is_r_mode'] = nil
vim.b['reticulate_running'] = false

-- wrap text, but by word no character
-- indent the wrappped line
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'

-- don't run vim ftplugin on top
vim.api.nvim_buf_set_var(0, 'did_ftplugin', true)

-- markdown vs. quarto hacks
local ns = vim.api.nvim_create_namespace 'QuartoHighlight'
vim.api.nvim_set_hl(ns, '@markup.strikethrough', { strikethrough = false })
vim.api.nvim_set_hl(ns, '@markup.doublestrikethrough', { strikethrough = true })
vim.api.nvim_win_set_hl_ns(0, ns)

-- ts based code chunk highlighting uses a change
-- only availabl in nvim >= 0.10
if vim.fn.has 'nvim-0.10.0' == 0 then
  return
end

-- highlight code cells similar to 'lukas-reineke/headlines.nvim'
local function setup_code_cell_highlighting(buf)
  buf = buf or api.nvim_get_current_buf()
  local parsername = 'markdown'
  local parser = ts.get_parser(buf, parsername)
  local tsquery = '(fenced_code_block)@codecell'
  
  -- Set the highlight style
  vim.api.nvim_set_hl(0, '@markup.codecell', {
    link = 'CursorLine',
  })
  
  -- Clear all existing extmarks
  local function clear_all()
    local all = api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
    for _, mark in ipairs(all) do
      vim.api.nvim_buf_del_extmark(buf, ns, mark[1])
    end
  end
  
  -- Apply highlighting to a range of lines
  local function highlight_range(from, to)
    for i = from, to do
      vim.api.nvim_buf_set_extmark(buf, ns, i, 0, {
        hl_eol = true,
        line_hl_group = '@markup.codecell',
      })
    end
  end
  
  -- Main highlighting function
  local function highlight_cells()
    clear_all()
    -- Make sure parser is up to date
    parser:parse()
    
    local query = ts.query.parse(parsername, tsquery)
    local tree = parser:parse()
    local root = tree[1]:root()
    
    for _, match, _ in query:iter_matches(root, buf, 0, -1, { all = true }) do
      for id, nodes in pairs(match) do
        for _, node in ipairs(nodes) do
          local start_line, _, end_line, _ = node:range()
          pcall(highlight_range, start_line, end_line - 1)
        end
      end
    end
  end
  
  -- Initial highlighting
  highlight_cells()
  
  -- Create a dedicated augroup for this buffer
  local group_name = 'QuartoCellHighlight_' .. buf
  local augroup = vim.api.nvim_create_augroup(group_name, { clear = true })
  
  -- Set up a more comprehensive set of autocommands to catch all changes
  vim.api.nvim_create_autocmd({
    'TextChanged',       -- Catches normal mode edits
    'TextChangedI',      -- Catches insert mode edits
    'TextChangedP',      -- Catches popup menu selections
    'BufWritePre',       -- Before saving
    'BufWritePost',      -- After saving
    'InsertLeave',       -- When leaving insert mode
    'ModeChanged',       -- When changing modes
    'CursorHold',        -- When cursor is stationary for a moment
  }, {
    group = augroup,
    buffer = buf,
    callback = highlight_cells,
  })
  
  -- If conform.nvim is used, try to catch its events too
  vim.api.nvim_create_autocmd('User', {
    pattern = {'ConformFormatPre', 'ConformFormatPost', 'FormatPre', 'FormatPost'},
    group = augroup,
    callback = function()
      vim.defer_fn(highlight_cells, 10)  -- Slight delay to ensure formatting is complete
    end,
  })
  
  -- Return the highlight function so it can be called manually if needed
  return highlight_cells
end

-- Set up for the current buffer
local highlight_update = setup_code_cell_highlighting()

-- Create a command to manually trigger highlighting
vim.api.nvim_create_user_command('RefreshCodeCells', highlight_update, {})
