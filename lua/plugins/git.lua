-- git plugins

return {
  { 'sindrets/diffview.nvim' },

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
