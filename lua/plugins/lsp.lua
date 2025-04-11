return {
  -- {
  --
  --   -- for lsp features in code cells / embedded code
  --   'jmbuhr/otter.nvim',
  --   enable = false,
  --   dev = false,
  --   dependencies = {
  --     {
  --       'neovim/nvim-lspconfig',
  --       'nvim-treesitter/nvim-treesitter',
  --     },
  --   },
  --   opts = {
  --     verbose = {
  --       no_code_found = false,
  --     }
  --   },
  -- },
  -- {
  --   'nvimdev/lspsaga.nvim',
  --   config = function()
  --     require('lspsaga').setup {}
  --   end,
  --   dependencies = {
  --     'nvim-treesitter/nvim-treesitter', -- optional
  --     'nvim-tree/nvim-web-devicons', -- optional
  --   },
  -- },
  {
    'neovim/nvim-lspconfig',
    -- event = 'VeryLazy',
    -- enable = false,
    dependencies = {
      { 'williamboman/mason.nvim', cmd = { 'Mason', 'MasonInstall' } },
      { 'williamboman/mason-lspconfig.nvim', cmd = 'Mason' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      {
        {
          'folke/lazydev.nvim',
          ft = 'lua', -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
          },
        },
        { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
        { -- optional completion source for require statements and module annotations
          'hrsh7th/nvim-cmp',
          opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
              name = 'lazydev',
              group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
          end,
        },
        -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
      },
      -- { 'folke/neoconf.nvim', opts = {}, enabled = false },
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local util = require 'lspconfig.util'

      require('mason').setup()
      require('mason-lspconfig').setup {
        automatic_installation = true,
      }
      require('mason-tool-installer').setup {
        ensure_installed = {
          'black',
          'stylua',
          'shfmt',
          'isort',
          'tree-sitter-cli',
          'jupytext',
          'air',
          'prettier',
          'tinymist',
          'markdown_oxide',
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local function vmap(keys, func, desc)
            vim.keymap.set('v', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, 'LSP client not found')

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          -- map('gS', vim.lsp.buf.document_symbol, '[g]o so [S]ymbols')
          -- map('gD', vim.lsp.buf.type_definition, '[g]o to type [D]efinition')
          -- map('gd', vim.lsp.buf.definition, '[g]o to [d]efinition')
          -- map('K', vim.lsp.buf.hover, '[K] hover documentation')
          -- map('gh', vim.lsp.buf.signature_help, '[g]o to signature [h]elp')
          -- map('gI', vim.lsp.buf.implementation, '[g]o to [I]mplementation')
          -- map('gr', vim.lsp.buf.references, '[g]o to [r]eferences')
          -- map('[d', function()
          --   vim.diagnostic.jump { count = 1 }
          -- end, 'previous [d]iagnostic ')
          -- map(']d', function()
          --   vim.diagnostic.jump { count = -1 }
          -- end, 'next [d]iagnostic ')
          -- map('<leader>ll', vim.lsp.codelens.run, '[l]ens run')
          -- map('<leader>lR', vim.lsp.buf.rename, '[l]sp [R]ename')
          -- map('<leader>lf', vim.lsp.buf.format, '[l]sp [f]ormat')
          -- vmap('<leader>lf', vim.lsp.buf.format, '[l]sp [f]ormat')
          -- map('<leader>lq', vim.diagnostic.setqflist, '[l]sp diagnostic [q]uickfix')
        end,
      })

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require('misc.style').border })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require('misc.style').border })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- also needs:
      -- $home/.config/marksman/config.toml :
      -- [core]
      -- markdown.file_extensions = ["md", "markdown", "qmd"]
      -- lspconfig.marksman.setup {
      --   capabilities = capabilities,
      --   filetypes = { 'markdown', 'quarto' },
      --   root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
      -- }

      require('lspconfig').r_language_server.setup {
        on_attach = function(client, _)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      }

      -- lspconfig.r_language_server.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   settings = {
      --     r = {
      --       lsp = {
      --         rich_documentation = false,
      --       },
      --     },
      --   },
      -- }

      lspconfig.ts_ls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'js', 'javascript', 'typescript', 'ojs' },
      }

      require('lspconfig')['tinymist'].setup {
        settings = {
          formatterMode = 'typstyle',
          exportPdf = 'onType',
          semanticTokens = 'disable',
        },
      }

      -- local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
      -- require('lspconfig').markdown_oxide.setup {
      --   -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
      --   -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
      --   capabilities = vim.tbl_deep_extend('force', capabilities, {
      --     workspace = {
      --       didChangeWatchedFiles = {
      --         dynamicRegistration = true,
      --       },
      --     },
      --   }),
      --   on_attach = on_attach, -- configure your on attach config
      -- }

      local function get_quarto_resource_path()
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
            table.insert(result, match)
          end
          return result
        end

        local f = assert(io.popen('quarto --paths', 'r'))
        local s = assert(f:read '*a')
        f:close()
        return strsplit(s, '\n')[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file('', true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once 'quarto not found, lua library files not loaded'
      else
        table.insert(lua_library_files, resource_path .. '/lua-types')
        table.insert(lua_plugin_paths, resource_path .. '/lua-plugin/plugin.lua')
      end

      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = {
              version = 'LuaJIT',
              -- plugin = lua_plugin_paths, -- handled by lazydev
            },
            diagnostics = {
              disable = { 'trailing-space' },
            },
            workspace = {
              -- library = lua_library_files, -- handled by lazydev
              checkThirdParty = false,
            },
            doc = {
              privateName = { '^_' },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }

      require('lspconfig').air.setup {
        on_attach = function(_, bufnr)
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end,
          })
        end,
      }

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too lags on linux for python projects
      -- because pyright and nvim both create too many watchers otherwise
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      lspconfig.pyright.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
            },
          },
        },
        root_dir = function(fname)
          return util.root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt')(fname) or util.path.dirname(fname)
        end,
      }

      local spell_words = {}
      for word in io.open(vim.fn.stdpath 'config' .. '/spell/en.utf-8.add', 'r'):lines() do
        table.insert(spell_words, word)
      end

      lspconfig.ltex.setup {
        filetypes = { 'markdown' },
        settings = {
          ltex = {
            language = 'en-GB',
            enabled = true,
            dictionary = {
              ['en-GB'] = spell_words,
            },
            disabledRules = {
              ['en-GB'] = {
                'OXFORD_SPELLING_Z_NOT_S', -- Stops suggesting '-ize' over '-ise'
                -- Add any other rule IDs you want to disable here
              },
            },
          },
        },
      }
    end,
  },
}
