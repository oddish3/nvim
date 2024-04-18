return {
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),  -- Use Tab to select and insert completion
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
        }),
        sources = {
          { name = 'vimtex', max_item_count = 5},  -- Ensure that 'vimtex' is a registered source in cmp-vimtex
        },
      })
    end
  },
}
