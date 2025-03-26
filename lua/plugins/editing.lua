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

  { -- format things as tables
    'godlygeek/tabular',
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    enabled = true,
    keys = {
      { '<leader>cf', '<cmd>lua require("conform").format()<cr>', desc = "[f]ormat" },
    },
    config = function()
      require('conform').setup {
        notify_on_error = false,
        -- format_on_save = {
        --   timeout_ms = 500,
        --   lsp_fallback = true,
        -- },
        formatters_by_ft = {
          lua = { 'mystylua' },
          python = { 'black' },
          quarto = { 'injected' },
          r = { 'air' },
        },
        formatters = {
          mystylua = {
            command = 'stylua',
            args = { '--indent-type', 'Spaces', '--indent-width', '2', '-' },
          },
          air = {
            command = 'air',
            args = { "format", "$FILENAME" },
            stdin = false,
          },
          black = {
            command = 'black',
            args = { '-' },
            stdin = true,  -- ensure Black reads from STDIN
          }
        },
      }
      -- Customize the "injected" formatter
      require('conform').formatters.injected = {
        -- Set the options field
        options = {
          -- Set to true to ignore errors
          ignore_errors = false,
          -- Map of treesitter language to file extension
          -- A temporary file name with this extension will be generated during formatting
          -- because some formatters care about the filename.
          lang_to_ext = {
            bash = 'sh',
            c_sharp = 'cs',
            elixir = 'exs',
            javascript = 'js',
            julia = 'jl',
            latex = 'tex',
            markdown = 'md',
            python = 'py',
            ruby = 'rb',
            rust = 'rs',
            teal = 'tl',
            r = 'r',
            typescript = 'ts',
          },
          -- Map of treesitter language to formatters to use
          -- (defaults to the value from formatters_by_ft)
          lang_to_formatters = {},
        },
      }
    end,
  },
}
