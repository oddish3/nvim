return {
  -- {
  --   'windwp/nvim-autopairs',
  --   config = function()
  --     -- Import the modules
  --     local npairs = require 'nvim-autopairs'
  --     local Rule = require 'nvim-autopairs.rule'
  --     local utils = require 'utils.luasnip-latex'
  --     -- print "[debug] Loaded 'utils.luasnip-latex' successfully."
  --     -- print "[debug] Loaded 'nvim-autopairs' successfully."
  --
  --     -- Setup basic configuration
  --     npairs.setup {
  --       check_ts = true,
  --       disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
  --     }
  --
  --     -- Remove backtick rule
  --     npairs.remove_rule '`'
  --     -- print '[debug] Removed the backtick rule.'
  --
  --     -- Create a more explicit condition with active feedback
  --     local function check_mathzone()
  --       local is_math = utils.in_mathzone()
  --       if is_math then
  --         -- vim.notify('In math zone - autopairs disabled', vim.log.levels.INFO)
  --       end
  --       return not is_math
  --     end
  --
  --     -- Setup an autocmd to test math zone detection directly
  --     vim.api.nvim_create_autocmd('InsertEnter', {
  --       pattern = { '*.tex', '*.md' },
  --       callback = function()
  --         local is_math = utils.in_mathzone()
  --         -- vim.notify('Math zone detection: ' .. tostring(is_math), vim.log.levels.INFO)
  --       end,
  --     })
  --
  --     -- print '[debug] Starting to modify autopairs rules...'
  --
  --     -- Explicitly clear and recreate rules with our condition
  --     npairs.clear_rules()
  --     -- print '[debug] Cleared existing rules'
  --
  --     -- Add common bracket pairs with our condition
  --     local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' }, { "'", "'" }, { '"', '"' } }
  --     for _, bracket in pairs(brackets) do
  --       -- print('[debug] Adding rule for: ' .. bracket[1] .. bracket[2])
  --       npairs.add_rule(Rule(bracket[1], bracket[2]):with_pair(check_mathzone):with_move(check_mathzone):with_cr(check_mathzone):with_del(check_mathzone))
  --     end
  --
  --     -- print '[debug] Autopairs setup complete with math zone condition'
  --   end,
  -- },
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
      vim.keymap.set('n', '<leader>cn', require('autolist').cycle_next_dr, { expr = true })
      vim.keymap.set('n', '<leader>cp', require('autolist').cycle_prev_dr, { expr = true })
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
        -- enabled = false,
        -- event = { "BufEnter", "InsertEnter" },
        -- lazy = true,
        ft = { 'markdown', 'norg', 'rmd', 'org', 'quarto' },
        config = function()
          require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/LuaSnip/' }
          require('luasnip-latex-snippets').setup { use_treesitter = true }
          require('luasnip').config.setup { enable_autosnippets = true }
        end,
        -- event = "BufEnter",
      },
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      -- 'uga-rosa/cmp-dictionary',
      -- { 'hrsh7th/cmp-buffer', event = "BufReadPost" },
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'jalvesaq/cmp-zotcite',
      'ray-x/cmp-treesitter',
      'jmbuhr/cmp-pandoc-references',
      'L3MON4D3/LuaSnip',
      'oddish3/friendly-snippets', -- n / note
      'onsails/lspkind-nvim',
      'R-nvim/cmp-r',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local function math_filter(entry, ctx)
        return require('luasnip-latex-snippets').filter_completion(entry, ctx)
      end
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
          { name = 'path' },
          { name = 'dictionary' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lsp' },
      {name = 'cmp_r'},
          -- { name = 'buffer' },
          { name = 'luasnip'},
          { name = 'pandoc_references' },
          -- { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          { name = 'spell', keyword_length = 5 },
          { name = 'treesitter', keyword_length = 5, max_item_count = 3 }, -- keyword_length = 3,
          { name = 'cmp_zotcite' },
        },
        -- cmp.setup.filetype({ 'r', 'quarto' }, {
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
      -- require('cmp_dictionary').setup {
      --   paths = { '/Users/user/.config/nvim/spell/en.utf-8.add' },
      --   -- exact_length = 2, -- Remove this if you want words of at least 2 characters
      -- }
      ls.config.setup {
        enable_autosnippets = true,
      }
      -- for friendly snippets
      -- require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
}

  --   {
  --   'saghen/blink.cmp',
  --   version = '1.*',
  --   dependencies = {
  --     -- Keep your core dependencies
  --     { 'L3MON4D3/LuaSnip', version = 'v2.*' },
  --     { 'oddish3/friendly-snippets' },
  --     {
  --       'saghen/blink.compat',
  --       opts = {
  --         impersonate_nvim_cmp = true,
  --         enable_events = true,
  --       },
  --     },
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-nvim-lsp-signature-help',
  --     'jalvesaq/cmp-zotcite',
  --     'jmbuhr/cmp-pandoc-references',
  --     {
  --       dir = '/Users/user/repos/public/luasnip-latex-snippets.nvim',
  --       ft = { 'markdown', 'norg', 'rmd', 'org', 'quarto' },
  --       config = function()
  --         require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/LuaSnip/' }
  --         require('luasnip-latex-snippets').setup { use_treesitter = true }
  --         require('luasnip').config.setup { enable_autosnippets = true }
  --       end,
  --     },
  --     'R-nvim/cmp-r',
  --   },
  --   opts = {
  --     snippets = {
  --       preset = 'luasnip',
  --       -- Enable autosnippets
  --     },
  --     keymap = {
  --       preset = 'enter',
  --       ['<C-f>'] = { 'scroll_docs_down' },
  --       ['<C-d>'] = { 'scroll_docs_up' },
  --       ['<C-n>'] = { 'select_next_item' },
  --       ['<C-p>'] = { 'select_prev_item' },
  --       ['<C-e>'] = { 'abort' },
  --       ['<CR>'] = { 'confirm' },
  --       ['<Tab>'] = { 'expand_or_jump' },
  --       ['<C-Space>'] = { 'complete' },
  --     },
  --     sources = {
  --       default = { 'lsp', 'lsp_signature', 'path', 'snippets', 'buffer' },
  --       providers = {
  --         -- LSP source
  --         lsp = {
  --           name = 'LSP',
  --           module = 'blink.compat.source',
  --           opts = {
  --             name = 'nvim_lsp',
  --           },
  --         },
  --         -- LSP Signature source
  --         lsp_signature = {
  --           name = 'Signature',
  --           module = 'blink.compat.source',
  --           opts = {
  --             name = 'nvim_lsp_signature_help',
  --           },
  --         },
  --         -- Custom snippets provider with LaTeX filtering
  --         snippets = {
  --           name = 'Snippets',
  --           module = 'blink.cmp.sources.snippets',
  --           opts = {
  --             show_autosnippets = true,
  --             use_show_condition = true,
  --             filter = function(item, ctx)
  --               -- Only apply the filter in specific filetypes
  --               if vim.tbl_contains({ 'markdown', 'quarto', 'tex', 'rmd' }, vim.bo.filetype) then
  --                 return require('luasnip-latex-snippets').filter_completion(item, ctx)
  --               end
  --               return true
  --             end,
  --           },
  --         },
  --         -- Add your R integration
  --         r = {
  --           name = 'R',
  --           module = 'cmp-r.blink',
  --           enabled = function()
  --             return vim.tbl_contains({ 'r', 'quarto', 'rmd' }, vim.bo.filetype)
  --           end,
  --         },
  --         -- Add pandoc references
  --         references = {
  --           name = 'pandoc_references',
  --           module = 'cmp-pandoc-references.blink',
  --           score_offset = 2,
  --           enabled = function()
  --             return vim.tbl_contains({ 'markdown', 'quarto', 'rmd' }, vim.bo.filetype)
  --           end,
  --         },
  --         -- Add Zotcite
  --         zotcite = {
  --           name = 'zotcite',
  --           module = 'cmp-zotcite.blink',
  --           enabled = function()
  --             return vim.tbl_contains({ 'markdown', 'quarto', 'rmd', 'tex' }, vim.bo.filetype)
  --           end,
  --         },
  --         -- Buffer source for fallback
  --         buffer = {
  --           name = 'Buffer',
  --           module = 'blink.cmp.sources.buffer',
  --           score_offset = -3,
  --         },
  --         -- Path source
  --         path = {
  --           name = 'Path',
  --           module = 'blink.cmp.sources.path',
  --           score_offset = 3,
  --         },
  --       },
  --     },
  --     appearance = {
  --       use_nvim_cmp_as_default = true,
  --       nerd_font_variant = 'mono',
  --     },
  --     completion = {
  --       documentation = {
  --         auto_show = true,
  --         auto_show_delay_ms = 100,
  --         treesitter_highlighting = true,
  --       },
  --     },
  --     signature = { enabled = true },
  --     -- Add LSP snippet handling configuration
  --     lsp = {
  --       snippet = {
  --         expand = function(snippet) vim.snippet.expand(snippet) end,
  --         active = function(filter) return vim.snippet.active(filter) end,
  --         jump = function(direction) vim.snippet.jump(direction) end,
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require('blink.cmp').setup(opts)
  --
  --     -- Load your R setup
  --     require('cmp_r').setup {}
  --
  --     -- Setup LuaSnip
  --     local ls = require 'luasnip'
  --     ls.config.setup {
  --       enable_autosnippets = true,
  --     }
  --
  --     -- Setup LSP capabilities
  --     local capabilities = vim.lsp.protocol.make_client_capabilities()
  --     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  --
  --     -- Configure Lua LSP
  --     require('lspconfig').lua_ls.setup({
  --       capabilities = capabilities,
  --       settings = {
  --         Lua = {
  --           completion = {
  --             callSnippet = "Disable",
  --             keywordSnippet = "Disable",
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
