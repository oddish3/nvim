return {

  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    'quarto-dev/quarto-nvim',
            enabled = false,
    ft = { 'quarto' },
    dev = false,
    opts = {},
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      -- 'jmbuhr/otter.nvim',
    },
  },
--   {
--     "R-nvim/R.nvim",
-- 		-- branch = "ascii_nvimcom",
--      -- Only required if you also set defaults.lazy = true
--     lazy = false,
--     -- R.nvim is still young and we may make some breaking changes from time
--     -- to time (but also bug fixes all the time). If configuration stability
--     -- is a high priority for you, pin to the latest minor version, but unpin
--     -- it and try the latest version before reporting an issue:
--     -- version = "~0.1.0"
--     config = function()
--         -- Create a table with the options to be passed to setup()
--         ---@type RConfigUserOpts
--         local opts = {
--             hook = {
--                 on_filetype = function()
--                     vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
--                     vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
--                     -- vim.api.nvim_buf_set_keymap(0, "u", "<LocalLeader>iu", "<Plug>RmdInsertChunk", {})
--                     -- vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>iu", "<Plug>RmdInsertChunk", { noremap = true })
--                      -- Emulate some of Nvim-R's default key bindings:
--                     vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>iu", "<Plug>RInsertAssign", { noremap = true })
--                     -- vim.api.nvim_buf_set_keymap(0, "i", "B", "<Plug>RmdInsertChunk", { noremap = true })
-- 						        vim.api.nvim_set_keymap("n", "<leader>wc", "<Cmd>lua require('r.rmd').write_chunk()<CR>", { noremap = true, silent = true })
--             				vim.api.nvim_set_keymap("n", "<leader>wa", "<Cmd>lua require('r.edit').assign()<CR>", { noremap = true, silent = true })
--
--                     vim.api.nvim_buf_set_keymap(0, "n", "<LocalLeader>im", "<Plug>RPackages", {})
--                 end
--             },
--             R_args = {"--quiet", "--no-save"},
--             min_editor_width = 100,
--             rconsole_width = 78,
--             objbr_mappings = { -- Object browser keymap
--                 c = 'class', -- Call R functions
--                 ['<localleader>gG'] = 'head({object}, n = 15)', -- Use {object} notation to write arbitrary R code.
--                 v = function()
--                     -- Run lua functions
--                     require('r.browser').toggle_view()
--                 end
--             },
--             disable_cmds = {
--                 "RClearConsole",
--                 "RCustomStart",
--                 "RSPlot",
--                 "RInsertPipe",
--                 "RSaveClose",
--             },
--         }
--         -- Check if the environment variable "R_AUTO_START" exists.
--         -- If using fish shell, you could put in your config.fish:
--         -- alias r "R_AUTO_START=true nvim"
--         if vim.env.R_AUTO_START == "true" then
--             opts.auto_start = "on startup"
--             opts.objbr_auto_start = true
--         end
--         require("r").setup(opts)
--     end,
-- },
  {
    "R-nvim/R.nvim",
    pdfviewer = 'zathura',
    -- dir = '/Users/user/repos/public/R.nvim',
    -- version = "0.1.0",
    -- enabled = false,
     -- Only required if you also set defaults.lazy = true
    -- lazy = false,
    -- version = "~0.9.0",
    -- R.nvim is still young and we may make some breaking changes from time
    -- to time (but also bug fixes all the time). If configuration stability
    -- is a high priority for you, pin to the latest minor version, but unpin
    -- it and try the latest version before reporting an issue:
    -- version = "~0.1.0"
    config = function()
        -- Create a table with the options to be passed to setup()
        ---@type RConfigUserOpts
        local opts = {
            hook = {
                on_filetype = function()
                    vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
                    vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
                end
            },
            R_args = {"--quiet", "--no-save"},
            min_editor_width = 72,
            rconsole_width = 78,
            objbr_mappings = { -- Object browser keymap
                c = 'class', -- Call R functions
                ['<localleader>gg'] = 'head({object}, n = 15)', -- Use {object} notation to write arbitrary R code.
                v = function()
                    -- Run lua functions
                    require('r.browser').toggle_view()
                end
            },
            disable_cmds = {
                "RClearConsole",
                "RCustomStart",
                "RSPlot",
                "RSaveClose",
                "RInsertPipe",
            },
        }
        -- Check if the environment variable "R_AUTO_START" exists.
        -- If using fish shell, you could put in your config.fish:
        -- alias r "R_AUTO_START=true nvim"
        if vim.env.R_AUTO_START == "true" then
            opts.auto_start = "on startup"
            opts.objbr_auto_start = true
        end
        require("r").setup(opts)
    end,
},
  {
  'HakonHarnes/img-clip.nvim',
                -- enabled = false,
  event = 'BufEnter',
  ft = { 'markdown', 'quarto', 'latex' },
  opts = {
    default = {
      dir_path = 'assets/private', -- Default to private storage
    },
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
      quarto = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
    },
  },
  config = function(_, opts)
    require('img-clip').setup(opts)
    
    -- Private image insertion
    vim.keymap.set('n', '<leader>ip', function()
      require('img-clip').pasteImage({ dir_path = 'assets/private' })
    end, { desc = 'Insert private image from clipboard' })
    
    -- Public image insertion
    vim.keymap.set('n', '<leader>iP', function()
      require('img-clip').pasteImage({ dir_path = 'assets/public' })
    end, { desc = 'Insert public image from clipboard' })
  end,
},
  { -- preview equations
    'jbyuki/nabla.nvim',
                -- enabled = false,
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },


}
