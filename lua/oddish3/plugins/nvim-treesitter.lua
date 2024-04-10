return {
  {
    "nvim-treesitter/nvim-treesitter", lazy = true,
   -- event = { "BufReadPre", "BufNewFile" },
    config = function()
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup({
        highlight = {
          enable = false,
        },
        indent = { enable = false },
        autotag = {
          enable = false, -- Disable autotag for non-markup languages
        },
        ensure_installed = {
          "latex", -- Add LaTeX language support
          "python", -- Add Python language support
        },
        incremental_selection = {
          enable = false
          ,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
}

