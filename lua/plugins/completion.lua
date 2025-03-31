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
    'gaoDean/autolist.nvim',
    ft = {
      'markdown',
      'text',
      'tex',
      'plaintex',
      'norg',
      'quarto', -- Ensure quarto is listed here
    },
    config = function()
      require('autolist').setup {
        lists = {
          quarto = {
            '[-+*]', -- unordered lists
            '%d+[.)]', -- ordered digit lists
            '%a[.)]', -- ascii lists
            '%u*[.)]', -- roman numeral lists
          },
        },
      }

      -- The keybindings in question
      vim.keymap.set('i', '<tab>', '<cmd>AutolistTab<cr>')
      vim.keymap.set('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>')
      vim.keymap.set('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>') -- This is the crucial one

      -- Other autolist mappings (keep or remove based on your testing needs)
      vim.keymap.set('n', 'o', 'o<cmd>AutolistNewBullet<cr>')
      vim.keymap.set('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>')
      -- vim.keymap.set('n', '<CR>', '<cmd>AutolistToggleCheckbox<cr><CR>') -- Normal mode CR might conflict with R.nvim send line, be careful
      vim.keymap.set('n', '>>', '>><cmd>AutolistRecalculate<cr>')
      vim.keymap.set('n', '<<', '<<<cmd>AutolistRecalculate<cr>')
      vim.keymap.set('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>')
      vim.keymap.set('v', 'd', 'd<cmd>AutolistRecalculate<cr>')
    end,
  },
  { -- completion
    'hrsh7th/nvim-cmp',
    -- enabled = false,
    -- event = "InsertEnter",
    dependencies = {
      {
        -- "aarnphm/luasnip-latex-snippets.nvim",
        dir = '/Users/user/repos/public/luasnip-latex-snippets.nvim',
        -- event = { "BufEnter", "InsertEnter" },
        -- lazy = true,
        ft = { 'markdown', 'norg', 'rmd', 'org', 'quarto' },
        config = function()
          require('luasnip-latex-snippets').setup { use_treesitter = true }
          require('luasnip').config.setup { enable_autosnippets = true }
        end,
        -- event = "BufEnter",
      },
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'uga-rosa/cmp-dictionary',
      -- { 'hrsh7th/cmp-buffer', event = "BufReadPost" },
      { 'hrsh7th/cmp-path', event = 'CursorHold' },
      'saadparwaiz1/cmp_luasnip',
      'jalvesaq/cmp-zotcite',
      'ray-x/cmp-treesitter',
      'jmbuhr/cmp-pandoc-references',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets', -- n / note
      'onsails/lspkind-nvim',
      'R-nvim/cmp-r',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local latex_snippets = require 'luasnip-latex-snippets'
      local lspkind = require 'lspkind'
      local ls = require 'luasnip'

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
          ['<C-n>'] = cmp.mapping.select_next_item { behavior = 'select' },
          ['<C-p>'] = cmp.mapping.select_prev_item { behavior = 'select' },
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item.
          -- Tab for snippet expansion ONLY
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-Space>'] = cmp.mapping.complete(),
        },
        autocomplete = false,

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            menu = {
              dictionary = '[dictionary]',
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
          -- { name = 'path' },
          -- { name = 'dictionary' },
          -- { name = 'nvim_lsp_signature_help' },
          -- { name = 'nvim_lsp' },
          -- { name = 'buffer' },
          -- -- { name = 'luasnip', keyword_length = 3, max_item_count = 3 },
          -- { name = 'pandoc_references' },
          -- { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          -- { name = 'spell' },
          -- { name = 'treesitter', max_item_count = 3 }, -- keyword_length = 3,
          -- { name = 'cmp_zotcite' },
          -- {
          --   name = 'luasnip', keyword_length = 3, max_item_count = 10,
          --   -- Only show math snippets in math zones and not in code blocks
          --   option = {
          --     show_autosnippets = true,
          --     -- You can filter snippets here based on context
          --     filter = function(snippet)
          --       -- Only show math snippets in math zones
          --       if snippet.context and snippet.context.math then
          --         return latex_snippets.is_in_math() and not latex_snippets.is_in_code_block()
          --       end
          --       return true
          --     end,
          --   },
          -- },
        },
        cmp.setup.filetype({ 'r', 'quarto', 'markdown' }, {
          sources = cmp.config.sources {
            { name = 'cmp_r' },
            { name = 'nvim_lsp' },
            {
              name = 'luasnip',
              keyword_length = 2,
              max_item_count = 10,
              option = {
                show_autosnippets = true,
              },
              entry_filter = function(entry, ctx)
                return require('luasnip-latex-snippets').filter_completion(entry, ctx)
              end,
            },
            { name = 'buffer' },
          },
        }),
        view = {
          entries = 'native',
        },
        -- window = {
        --   documentation = cmp.config.disable
        --     -- {border = require('misc.style').border,},
        -- },
      }
      -- vim.api.nvim_create_autocmd('FileType', {
      --   pattern = 'r',
      --   callback = function()
      --     vim.keymap.del('i', '<Tab>') -- Remove AutolistTab in R files
      --   end,
      -- })
      require('cmp_r').setup {}
      require('cmp_dictionary').setup {
        paths = { '/Users/user/.config/nvim/spell/en.utf-8.add' },
        -- exact_length = 2, -- Remove this if you want words of at least 2 characters
      }
      ls.config.setup {
        enable_autosnippets = true,
      }
      -- for friendly snippets
      require('luasnip.loaders.from_vscode').lazy_load()
      -- vim.api.nvim_create_autocmd('FileType', {
      --   pattern = { 'r', 'qmd' }, -- Corrected pattern
      --   callback = function()
      --     vim.keymap.del('i', '<Tab>') -- Remove AutolistTab in R and Quarto files
      --   end,
      -- })
      -- for custom snippets
      require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/LuaSnip/' }
    end,
  },
}
