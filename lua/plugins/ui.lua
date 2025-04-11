return {
{
  "folke/snacks.nvim",
   enabled = false,
  ---@type snacks.Config
  opts = {
    image = {
      -- your image configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  }
},
  -- lazy.nvim
  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {},
  },
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- { 'nvim-telescope/telescope-dap.nvim' },
      { 'benfowler/telescope-luasnip.nvim' },
      {
        'jmbuhr/telescope-zotero.nvim',
        dependencies = {
          { 'kkharji/sqlite.lua' },
        },
        cmd = 'Telescope zotero',
        config = function()
          -- Create a module-level variable to track the current mode
          local use_locate_function = false
          local default_bib_path = '/Users/user/repos/quartz/content/bib.bib'

          -- Define a utility function that handles either approach
          local function get_bib_location()
            print('[DEBUG] Entering get_bib_location. use_locate_function =', use_locate_function)

            if use_locate_function then
              print '[DEBUG] use_locate_function is true. Attempting to use locate function.'
              local bib = require 'zotero.bib'
              local path = bib.locate_quarto_bib()
              print('[DEBUG] locate_quarto_bib returned:', path)

              -- If the path is relative (doesn't start with '/'), convert it to an absolute path
              if not path:match '^/' then
                local dir = vim.fn.expand '%:p:h' -- Get the directory of the current file
                path = dir .. '/' .. path
                print('[DEBUG] Converted relative path to absolute path:', path)
              end

              local abs_path = vim.fn.expand(path, ':p')
              print('[DEBUG] Expanded absolute path is:', abs_path)

              local readable = vim.fn.filereadable(abs_path)
              print('[DEBUG] File readability check returned:', readable, 'for', abs_path)
              if abs_path and readable == 1 then
                print('[DEBUG] File is readable at path:', abs_path)
                return abs_path
              end

              -- If not found, try to find references.bib in the current directory
              local current_dir = vim.fn.expand '%:p:h'
              local references_path = current_dir .. '/references.bib'
              print('[DEBUG] Checking for references.bib in current directory at:', references_path)

              if vim.fn.filereadable(references_path) == 1 then
                print('[DEBUG] Found readable references file at:', references_path)
                return references_path
              end

              vim.notify('Could not locate bibliography file, falling back to default path', vim.log.levels.WARN)
              print('[DEBUG] Falling back to default_bib_path:', default_bib_path)
              return default_bib_path
            else
              print('[DEBUG] use_locate_function is false. Using default_bib_path:', default_bib_path)
              return default_bib_path
            end
          end

          -- Function to toggle between the two modes
          local function toggle_bib_location_mode()
            use_locate_function = not use_locate_function
            local mode = use_locate_function and 'locate function' or 'fixed path'
            vim.notify('Zotero bib location mode: ' .. mode, vim.log.levels.INFO)
          end

          -- Make the toggle function available globally
          _G.toggle_zotero_bib_mode = toggle_bib_location_mode

          require('zotero').setup {
            ft = {
              md = {
                insert_key_formatter = function(citekey)
                  return '@' .. citekey
                end,
                locate_bib = function()
                  return get_bib_location()
                end,
              },
              default = {
                insert_key_formatter = function(citekey)
                  return '@' .. citekey
                end,
                locate_bib = function()
                  return get_bib_location()
                end,
              },
            },
          }
          require('telescope').load_extension 'zotero'

          -- Set up keybindings
          vim.keymap.set('n', '<leader>fz', ':Telescope zotero<cr>', { desc = '[z]otero' })
          vim.keymap.set('n', '<leader>zt', function()
            _G.toggle_zotero_bib_mode()
          end, { desc = '[z]otero [t]oggle bib mode' })
        end,
      },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local previewers = require 'telescope.previewers'
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then
            return
          end
          if stat.size > 100000 then
            return
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      end

      local telescope_config = require 'telescope.config'
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      -- I don't want to search in the `docs` directory (rendered quarto output).
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!docs/*')

      telescope.setup {
        defaults = {
          buffer_previewer_maker = new_maker,
          vimgrep_arguments = vimgrep_arguments,
          file_ignore_patterns = {
            'node_modules',
            '%_cache',
            '.git/',
            'site_libs',
            '.venv',
          },
          layout_strategy = 'flex',
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<esc>'] = actions.close,
              ['<c-j>'] = actions.move_selection_next,
              ['<c-k>'] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            find_command = {
              'rg',
              '--files',
              '--hidden',
              '--glob',
              '!.git/*',
              '--glob',
              '!**/.Rpro.user/*',
              '--glob',
              '!_site/*',
              '--glob',
              '!docs/**/*.html',
              '-L',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          },
        },
      }
      telescope.load_extension 'fzf'
      telescope.load_extension 'ui-select'
      -- telescope.load_extension 'dap'
      telescope.load_extension 'zotero'
    end,
  },

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- edit the file system as a buffer
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ['<C-s>'] = false,
        ['<C-h>'] = false,
        ['<C-l>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', ':Oil<cr>', desc = 'oil' },
      { '<leader>ef', ':Oil<cr>', desc = 'edit [f]iles' },
    },
    cmd = 'Oil',
  },
  { -- scrollbar
    'dstein64/nvim-scrollview',
    enabled = true,
    opts = {
      current_only = true,
    },
  },
  -- show keybinding help window
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup {}
      require 'config.keymap'
    end,
  },

  { -- show tree of symbols in the current file
    'hedyhli/outline.nvim',
    cmd = 'Outline',
    keys = {
      { '<leader>lo', ':Outline<cr>', desc = 'symbols outline' },
    },
    opts = {
      providers = {
        priority = { 'markdown', 'lsp', 'norg' },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { 'markdown', 'quarto' },
        },
      },
    },
  },
  -- { -- or show symbols in the current file as breadcrumbs
  --   'Bekaboo/dropbar.nvim',
  --   enabled = function()
  --     return vim.fn.has 'nvim-0.10' == 1
  --   end,
  --   dependencies = {
  --     'nvim-telescope/telescope-fzf-native.nvim',
  --   },
  --   config = function()
  --     -- turn off global option for windowline
  --     vim.opt.winbar = nil
  --     vim.keymap.set('n', '<leader>ls', require('dropbar.api').pick, { desc = '[s]ymbols' })
  --   end,
  -- },

  { -- terminal
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
    },
  },
  { -- show indent lines
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPost',
    main = 'ibl',
    opts = {
      indent = { char = '│' },
    },
  },
  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = false,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    cond = function()
      -- Disable on Windows system
      return vim.fn.has 'win32' ~= 1
    end,
    dependencies = {
      'leafo/magick', -- that's a lua rock
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt install lua5.1
      -- sudo apt install luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        kitty_method = 'direct', -- Try 'direct' instead of 'normal'
        kitty_tmux_fallback = true,
        clear_in_insert_mode = true,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            -- only_render_image_at_cursor_mode = "popup",
            resolve_image_path = function(document_path, image_path, fallback)
              -- Print debugging information
              -- print("Document path: " .. document_path)
              -- print("Image path: " .. image_path)

              local anki_media = vim.fn.expand '~/Library/Application Support/Anki2/User 1/collection.media'

              -- Check if the image path looks like an Anki media reference (no directories)
              if image_path:match '^[^/\\]+%.%w+$' then
                local full_anki_path = anki_media .. '/' .. image_path

                -- print("Checking Anki path: " .. full_anki_path)

                -- Check if the file exists in Anki media
                if vim.fn.filereadable(full_anki_path) == 1 then
                  -- print("Found image in Anki media!")
                  return full_anki_path
                else
                  -- print("Image not found in Anki media")
                end
              end

              -- Try the default behavior
              local default_path = fallback(document_path, image_path)
              -- print("Fallback path: " .. default_path)
              return default_path
            end,
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = 'normal',
      }
    end,
  },
}
