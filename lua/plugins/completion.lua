return {
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
    -- enabled = false,
    event = 'InsertEnter',
    dependencies = {
{
    "gaoDean/autolist.nvim",
    -- enabled = false,
    ft = {
        "markdown",
        "text",
        "tex",
        "plaintex",
        "norg",
        "quarto"
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
      'hrsh7th/cmp-path',
      -- 'hrsh7th/cmp-calc',
      -- 'hrsh7th/cmp-emoji',
      'f3fora/cmp-spell',
      -- 'ray-x/cmp-treesitter',
      -- 'kdheepak/cmp-latex-symbols',
      'jalvesaq/cmp-zotcite',
      'quangnguyen30192/cmp-nvim-ultisnips',
{
  "SirVer/ultisnips",
  lazy = false,
  config = function()
    vim.g.UltiSnipsExpandTrigger = "<tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
  end,
},
    },
    config = function()
      local cmp = require 'cmp'
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

        sources = {
          { name = 'path' },
          { name = 'ultisnips', keyword_length = 3, max_item_count = 3 },
          { name = "cmp_zotcite" },
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
