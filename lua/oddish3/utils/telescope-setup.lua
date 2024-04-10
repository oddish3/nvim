-- lua/oddish3/config/utils/telescope_setup.lua
local telescope = require('telescope')
local builtin = require('telescope.builtin')

local M = {}

function M.CustomLiveGrep()
  local opts = {} -- Customize your options here
  opts.search_dirs = {"/home/oddish3/.config/nvim/UltiSnips/tex.snippets", "/home/oddish3/Documents/uni/mast-2/notation.tex", "/home/oddish3/current_course/UltiSnips/tex.snippets"} -- Example directories
  builtin.live_grep(opts)
end

return M

