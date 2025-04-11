-- git plugins
return {
  { 'sindrets/diffview.nvim' },
  { 'tpope/vim-fugitive' },
  {
    'mrloop/telescope-git-branch.nvim',
  },
  -- {
  --   'f-person/git-blame.nvim',
  --   -- load the plugin at startup
  --   event = 'VeryLazy',
  --   -- Because of the keys part, you will be lazy loading this plugin.
  --   -- The plugin wil only load once one of the keys is used.
  --   -- If you want to load the plugin at startup, add something like event = "VeryLazy",
  --   -- or lazy = false. One of both options will work.
  --   opts = {
  --     -- your configuration comes here
  --     -- for example
  --     enabled = true, -- if you want to enable the plugin
  --     message_template = ' <summary> • <date> • <author> • <<sha>>', -- template for the blame message, check the Message template section for more options
  --     date_format = '%m-%d-%Y %H:%M:%S', -- template for the date, check Date format section for more options
  --     virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
  --   },
  -- },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('octo').setup()
    end,
  },
  -- handy git ui
  {
    'NeogitOrg/neogit',
    -- version = '1.0.0',
    lazy = true,
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', ':Neogit<cr>', desc = 'neo[g]it' },
    },
    config = function()
      require('neogit').setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
      }
    end,
  },
}
