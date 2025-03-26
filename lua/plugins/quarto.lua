return {

  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    'quarto-dev/quarto-nvim',
            enabled = false,
    ft = { 'quarto' },
    dev = false,
    opts = {},
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      'jmbuhr/otter.nvim',
    },
  },
  {
    "R-nvim/R.nvim",
    -- enabled = false,
     -- Only required if you also set defaults.lazy = true
    lazy = false,
    -- R.nvim is still young and we may make some breaking changes from time
    -- to time (but also bug fixes all the time). If configuration stability
    -- is a high priority for you, pin to the latest minor version, but unpin
    -- it and try the latest version before reporting an issue:
    -- version = "~0.1.0"
    config = function()
        -- Create a table with the options to be passed to setup()
        ---@type RConfigUserOpts
        local opts = {
            hook = {
                on_filetype = function()
                    vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
                    vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
                end
            },
            R_args = {"--quiet", "--no-save"},
            min_editor_width = 72,
            rconsole_width = 78,
            objbr_mappings = { -- Object browser keymap
                c = 'class', -- Call R functions
                ['<localleader>gg'] = 'head({object}, n = 15)', -- Use {object} notation to write arbitrary R code.
                v = function()
                    -- Run lua functions
                    require('r.browser').toggle_view()
                end
            },
            disable_cmds = {
                "RClearConsole",
                "RCustomStart",
                "RSPlot",
                "RSaveClose",
                "RInsertPipe",
            },
        }
        -- Check if the environment variable "R_AUTO_START" exists.
        -- If using fish shell, you could put in your config.fish:
        -- alias r "R_AUTO_START=true nvim"
        if vim.env.R_AUTO_START == "true" then
            opts.auto_start = "on startup"
            opts.objbr_auto_start = true
        end
        require("r").setup(opts)
    end,
},

  { -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    'GCBallesteros/jupytext.nvim',
            enabled = false,

    opts = {
      custom_language_formatting = {
        python = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto',
        },
        r = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto',
        },
      },
    },
  },

  { -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    'jpalardy/vim-slime',
            enabled = false,
    dev = false,
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        require('otter.tools.functions').is_otter_language_context 'python'
      end

      vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

      vim.g.slime_target = 'neovim'
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

      local function mark_terminal()
        local job_id = vim.b.terminal_job_id
        vim.print('job_id: ' .. job_id)
      end

      local function set_terminal()
        vim.fn.call('slime#config', {})
      end
      vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
      vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
    end,
  },
  {
  'HakonHarnes/img-clip.nvim',
                -- enabled = false,
  event = 'BufEnter',
  ft = { 'markdown', 'quarto', 'latex' },
  opts = {
    default = {
      dir_path = 'assets/private', -- Default to private storage
    },
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
      quarto = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
    },
  },
  config = function(_, opts)
    require('img-clip').setup(opts)
    
    -- Private image insertion
    vim.keymap.set('n', '<leader>ip', function()
      require('img-clip').pasteImage({ dir_path = 'assets/private' })
    end, { desc = 'Insert private image from clipboard' })
    
    -- Public image insertion
    vim.keymap.set('n', '<leader>iP', function()
      require('img-clip').pasteImage({ dir_path = 'assets/public' })
    end, { desc = 'Insert public image from clipboard' })
  end,
},
  { -- preview equations
    'jbyuki/nabla.nvim',
                -- enabled = false,
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },

  {
    'benlubas/molten-nvim',
    enabled = false,
    build = ':UpdateRemotePlugins',
    init = function()
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
    end,
    keys = {
      { '<leader>mi', ':MoltenInit<cr>', desc = '[m]olten [i]nit' },
      {
        '<leader>mv',
        ':<C-u>MoltenEvaluateVisual<cr>',
        mode = 'v',
        desc = 'molten eval visual',
      },
      { '<leader>mr', ':MoltenReevaluateCell<cr>', desc = 'molten re-eval cell' },
    },
  },
}
