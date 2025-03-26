return {
  {
    'windwp/nvim-autopairs',
        -- enabled = false,
    config = function()
      require('nvim-autopairs').setup {}
      require('nvim-autopairs').remove_rule '`'
    end,
  },
{
    "gaoDean/autolist.nvim",
    -- enabled = false,
    ft = {
        "markdown",
        "text",
        "tex",
        "plaintex",
        "norg",
        "quarto",
    },
    config = function()
        require("autolist").setup()

        vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
        vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
        -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
        vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
        vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
        vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
        vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
        -- vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

        -- cycle list types with dot-repeat
        vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
        vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

        -- if you don't want dot-repeat
        -- vim.keymap.set("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
        -- vim.keymap.set("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")

        -- functions to recalculate list on edit
        vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
        vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
        vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
        vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
    end,
  },
  { -- completion
    'hrsh7th/nvim-cmp',
        -- enabled = false,
    event = 'InsertEnter',
    dependencies = {
      {
    -- "aarnphm/luasnip-latex-snippets.nvim",
      dir = "/Users/user/repos/public/luasnip-latex-snippets.nvim",
    version = false,
    lazy = true,
    ft = { "markdown", "norg", "rmd", "org" },
    config = function()
      require("luasnip-latex-snippets").setup { use_treesitter = true }
      require("luasnip").config.setup { enable_autosnippets = true }
      -- require("luasnip.loaders.from_lua").load({paths = "/Users/user/.config/quarto-nvim-kickstarter/lua/snips"})
    end,
  },
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      -- 'hrsh7th/cmp-calc',
      -- 'hrsh7th/cmp-emoji',
      'saadparwaiz1/cmp_luasnip',
      'jalvesaq/cmp-zotcite',
      -- 'f3fora/cmp-spell',
      'ray-x/cmp-treesitter',
      -- 'kdheepak/cmp-latex-symbols',
      'jmbuhr/cmp-pandoc-references',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets', -- n / note
      'onsails/lspkind-nvim',
      "R-nvim/cmp-r",
      -- 'jmbuhr/otter.nvim',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      local ls = require("luasnip")

      -- local has_words_before = function()
      --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      -- end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = {
  ['<C-f>'] = cmp.mapping.scroll_docs(-4),
  ['<C-d>'] = cmp.mapping.scroll_docs(4),

  ['<C-n>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
  ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.

  -- Tab for snippet expansion ONLY
  ['<Tab>'] = cmp.mapping(function(fallback)
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end, { 'i', 's' }),
  --
  -- ['<S-Tab>'] = cmp.mapping(function(fallback)
  --   if cmp.visible() then
  --     cmp.select_prev_item()
  --   else
  --     fallback()
  --   end
  -- end, { 'i', 's' }),
  --
  -- -- Manual completion menu trigger
  ['<C-Space>'] = cmp.mapping.complete(),
},
        autocomplete = false,

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            menu = {
              otter = '[🦦]',
              nvim_lsp = '[LSP]',
              nvim_lsp_signature_help = '[sig]',
              luasnip = '[snip]',
              buffer = '[buf]',
              path = '[path]',
              spell = '[spell]',
              pandoc_references = '[ref]',
              tags = '[tag]',
              treesitter = '[TS]',
              calc = '[calc]',
              latex_symbols = '[tex]',
              cmp_r = '[R]',
              emoji = '[emoji]',
            },
          },
        },
        sources = {
          -- { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lsp' },
          { name = 'luasnip', keyword_length = 3, max_item_count = 3 },
          { name = 'pandoc_references' },
          { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          { name = 'spell' },
          { name = 'treesitter', max_item_count = 3 },  -- keyword_length = 3,
          { name = "cmp_zotcite" },
          { name = 'calc' },
          { name = 'latex_symbols' },
          { name = "cmp_r" },
          { name = 'emoji' },
        },
        view = {
          entries = 'native',
        },
        window = {
          documentation = {
            border = require('misc.style').border,
          },
        },
      }
      require("cmp_r").setup({})
ls.config.setup({
    enable_autosnippets = true,
})
      -- for friendly snippets
      -- require('luasnip.loaders.from_vscode').lazy_load()
      require("luasnip.loaders.from_vscode").load {
      exclude = { "markdown.Insert Note" },
  }
      -- for custom snippets
      -- require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snips' } }
      require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})
-- print("Loaded snippets from: " .. vim.fn.expand("~/.config/quarto-nvim-kickstarter/LuaSnip/"))
-- vim.api.nvim_command("messages")  -- This will show the print in Neovim

      -- require('luasnip.loaders.from_lua').lazy_load { paths = { vim.fn.stdpath 'config' .. '/lua/snips' } }
      -- require("luasnip.loaders.from_lua").load({paths = "/Users/user/.config/quarto-nvim-kickstarter/lua/snips"})
      -- print("LuaSnip Lua loaders are being loaded from: " .. vim.fn.stdpath 'config' .. '/lua/snips')
      -- link quarto and rmarkdown to markdown snippets
      luasnip.filetype_extend('quarto', { 'markdown' })
      luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
  }
}
