return {
  "nvim-telescope/telescope.nvim", lazy = true, 
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        -- Enhanced fuzzy find configurations
        ignore_case = true,  -- Make searches case-insensitive
        smart_case = true,   -- Searches are case-sensitive only if the query contains uppercase letters
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next,    -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            width = 0.8,  -- 80% of screen width
            height = 0.5, -- 50% of screen height, adjust as necessary
            preview_width = 0.5,
          },
          vertical = {
            width = 0.8,
            height = 0.8,
            preview_height = 0.5,
          },
        },
        -- Ignore files and directories
        file_ignore_patterns = {"%.git/", "node_modules"},
      },
    })

    -- Load the fzf native extension for better performance
    telescope.load_extension("fzf")
  end,
}

