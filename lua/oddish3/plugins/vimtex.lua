return {
  "lervag/vimtex", -- Assuming you're using a plugin manager to load vimtex
  priority = 999, 
  config = function()
    vim.g.tex_flavor = "latex"
    vim.g.tex_conceal = "abdmg"
    vim.g.python3_host_prog = '/usr/bin/python3'
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_quickfix_mode = 0

    -- Additional vimtex-specific configurations could go here
  end,
}

