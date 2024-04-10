-- lua/config/tokyonight.lua
return
{
  "folke/tokyonight.nvim",
  priority = 1000, -- Ensures TokyoNight loads before other plugins
  config = function()
    -- Apply the TokyoNight color scheme
    vim.cmd("colorscheme tokyonight")
  end,
}


