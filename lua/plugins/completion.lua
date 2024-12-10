return {
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
      require('nvim-autopairs').remove_rule '`'
    end,
  },
{
        "jalvesaq/zotcite",
    lazy = false,
	-- dir = "/Users/user/repos/projects/public/zotcite",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("zotcite").setup({
                -- your options here (see doc/zotcite.txt)
            })
        end,
    },
  { -- completion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
{
    "gaoDean/autolist.nvim",
    ft = {
        "markdown",
        "text",
        "tex",
        "plaintex",
        "norg",
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
        vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

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
{
      "windwp/nvim-autopairs",
        enabled = false,
      opts = { fast_wrap = {}, disable_filetype = { "TelescopePrompt", "vim" } },
      config = function(_, opts)
        require("nvim-autopairs").setup(opts)
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'f3fora/cmp-spell',
      'ray-x/cmp-treesitter',
      'kdheepak/cmp-latex-symbols',
      'jmbuhr/cmp-pandoc-references',
      'jalvesaq/cmp-zotcite',
      'onsails/lspkind-nvim',
      'jmbuhr/otter.nvim',
      'quangnguyen30192/cmp-nvim-ultisnips',
{
  "SirVer/ultisnips",
  config = function()
    vim.g.UltiSnipsExpandTrigger = "<tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
  end,
},
    },
    config = function()
      local cmp = require 'cmp'
      local lspkind = require 'lspkind'
      require("cmp_nvim_ultisnips").setup{}
      local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = {
        ["<Tab>"] = cmp.mapping(
          function(fallback)
            cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
          end,
          { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
        ),
        ["<S-Tab>"] = cmp.mapping(
          function(fallback)
            cmp_ultisnips_mappings.jump_backwards(fallback)
          end,
          { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
        ),
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
              ultisnip = '[snip]',
              -- buffer = '[buf]',
              path = '[path]',
              spell = '[spell]',
              pandoc_references = '[ref]',
              tags = '[tag]',
              treesitter = '[TS]',
              calc = '[calc]',
              latex_symbols = '[tex]',
              emoji = '[emoji]',
            },
          },
        },
        sources = {
          { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lsp' },
          { name = 'ultisnips', keyword_length = 3, max_item_count = 3 },
          { name = "cmp_zotcite" },
          { name = 'pandoc_references' },
          -- { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          -- { name = 'spell' },
          { name = 'treesitter', keyword_length = 5, max_item_count = 3 },
          { name = 'calc' },
          { name = 'latex_symbols' },
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

      -- link quarto and rmarkdown to markdown snippets
      -- luasnip.filetype_extend('quarto', { 'markdown' })
      -- luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
  },
}
