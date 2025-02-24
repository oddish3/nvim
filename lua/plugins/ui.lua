return {
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
{
  'jmbuhr/telescope-zotero.nvim',
  dependencies = {
    { 'kkharji/sqlite.lua' },
  },
  config = function()
    require('zotero').setup({
      ft = {
        md = {
          insert_key_formatter = function(citekey)
            return '@' .. citekey
          end,
          locate_bib = function()
            return "/Users/user/repos/quartz/content/bib.bib"
          end,
        },
        default = {
          insert_key_formatter = function(citekey)
            return '@' .. citekey
          end,
          locate_bib = function()
            return "/Users/user/repos/quartz/content/bib.bib"
          end,
        }
      }
    })
    require('telescope').load_extension('zotero')
    vim.keymap.set('n', '<leader>fz', ':Telescope zotero<cr>', { desc = '[z]otero' })
  end,
},
      {'cljoly/telescope-repo.nvim'},
      {'jvgrootveld/telescope-zoxide'},
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
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = 'smart_case',       -- or "ignore_case" or "respect_case"
          },
        },
      }
      telescope.load_extension 'fzf'
      telescope.load_extension 'ui-select'
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
      { '-',          ':Oil<cr>', desc = 'oil' },
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
    enabled = true,
    event = 'VeryLazy',
    config = function()
      require('which-key').setup {}
      require 'config.keymap'
    end,
  },
  { -- or show symbols in the current file as breadcrumbs
    'Bekaboo/dropbar.nvim',
    enabled = function()
      return vim.fn.has 'nvim-0.10' == 1
    end,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      -- turn off global option for windowline
      vim.opt.winbar = nil
      vim.keymap.set('n', '<leaderls', require('dropbar.api').pick, { desc = '[s]ymbols' })
    end,
  },
  { -- terminal
  'akinsho/toggleterm.nvim',
  opts = {
    open_mapping = [[<leader>tt]],
    direction = 'float',
  },
},
  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = true,
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
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            -- only_render_image_at_cursor_mode = "popup",
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

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value('columns', {})
        local win_height = vim.api.nvim_get_option_value('lines', {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })
        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      vim.keymap.set('n', '<leader>io', function()
        local bufnr = vim.api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      vim.keymap.set('n', '<leader>ic', clear_all_images, { desc = 'image [c]lear' })
    end,
  },
{
  'HakonHarnes/img-clip.nvim',
  event = 'BufEnter',
  ft = { 'markdown', 'quarto', 'latex' },
  config = function()
    -- Function to check if we're in the vault directory structure and get the root
    local function get_vault_root()
      local current_dir = vim.fn.expand('%:p:h')
      local vault_path = vim.fn.expand('~/vault')
      
      if vim.startswith(current_dir, vault_path) then
        return vault_path
      end
      return nil
    end

    -- Function to calculate relative path from current file to assets directory
    local function get_relative_assets_path()
      local current_file_dir = vim.fn.expand('%:p:h')
      local vault_root = vim.fn.expand('/Users/user/repos/quartz/content/')
      
      -- If we're in the vault root, return just 'assets'
      if current_file_dir == vault_root then
        return 'assets'
      end
      
      -- Get the path components for nested directories
      local current_parts = vim.split(current_file_dir:sub(vault_root:len() + 2), '/')
      
      -- Calculate number of levels to go up
      local levels_up = #current_parts
      
      -- Build the relative path
      return string.rep('../', levels_up) .. 'assets'
    end

    -- Function to check if clipboard contains an image on macOS
    local function has_image_in_clipboard()
      if vim.fn.has('macunix') == 1 then
        local handle = io.popen('osascript -e "clipboard info" 2>/dev/null')
        if handle then
          local result = handle:read("*a")
          handle:close()
          return result:match("«class PNGf»") ~= nil
        end
      end
      return false
    end

    -- Common function to handle image pasting
    local function paste_to_assets(is_private)
      -- Check if we're somewhere in the vault structure
      local vault_root = get_vault_root()
      if not vault_root then
        vim.notify("Not in vault directory structure!", vim.log.levels.ERROR)
        return
      end

      -- Then check for image in clipboard
      if not has_image_in_clipboard() then
        vim.notify("No image found in clipboard!", vim.log.levels.ERROR)
        return
      end

      local filename = vim.fn.input('Enter image filename (without extension): ')
      if filename == '' then return end

      local dir_type = is_private and 'private' or 'public'
      local assets_dir = string.format('%s/assets/%s', vault_root, dir_type)
      
      -- Ensure the assets directory exists
      vim.fn.mkdir(assets_dir, 'p')
      
      -- Calculate the relative path for the markdown link
      local relative_assets = get_relative_assets_path()
      
      -- Use the API directly with options
      require('img-clip').paste_image({
        dir_path = assets_dir,
        relative_to_current_file = false,  -- Use absolute path for saving
        prompt_for_file_name = false,
        file_name = filename,
        -- Use the calculated relative path in the template
        template = string.format('![Image](%s/%s/%s.png)', relative_assets, dir_type, filename)
      })
    end

    -- Keymap for public assets
    vim.keymap.set('n', '<leader>ip', function()
      paste_to_assets(false)
    end, { desc = 'Paste image to public assets folder' })

    -- Keymap for private assets
    vim.keymap.set('n', '<leader>iP', function()
      paste_to_assets(true)
    end, { desc = 'Paste image to private assets folder' })
  end
},
  {
    "tpope/vim-obsession",
    event = "VeryLazy", -- Optional: Load only when needed
  }
}
