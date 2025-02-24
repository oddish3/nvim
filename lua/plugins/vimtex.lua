return {
  "lervag/vimtex", -- Assuming you're using a plugin manager to load vimtex
  priority = 999, 
  -- ft = { 'tex', 'markdown', 'quarto' },
  config = function()
    vim.g.tex_flavor = "latex"
    vim.g.tex_conceal = "abdmg"
    vim.g.python3_host_prog = ''
    vim.g.vimtex_view_method = ""
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_indent_lists = {} -- Corrected: Use curly braces for an empty table in Lua
    -- Additional vimtex-specific configurations could go here
  end,
}

