return {

  -- disables hungry features for files larget than 2MB
  { 'LunarVim/bigfile.nvim' },

  -- add/delete/change can be done with the keymaps
  -- ys{motion}{char}, ds{char}, and cs{target}{replacement}
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  { -- commenting with e.g. `gcc` or `gcip`
    -- respects TS, so it works in quarto documents 'numToStr/Comment.nvim',
    'numToStr/Comment.nvim',
    version = nil,
    cond = function()
      return vim.fn.has 'nvim-0.10' == 0
    end,
    branch = 'master',
    config = true,
  },
  -- interactive global search and replace
  {
    'nvim-pack/nvim-spectre',
    cmd = { 'Spectre' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
}
