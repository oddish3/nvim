local function check_caps_lock()
    local handle = io.popen("xset q | grep 'Caps Lock:' | awk '{print $4}'")
    local result = handle:read("*a")
    handle:close()

    if result:find("on") then
        return "CAPS"
    else
        return ""
    end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    "sirver/ultisnips",
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
    end
  },
  {
    "lervag/vimtex",
    config = function()
      vim.g.tex_flavor = "latex"
      vim.g.tex_conceal = "abdmg"
      vim.g.python3_host_prog = '/usr/bin/python3'
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
    end
  },
  {
    "KeitaNakamura/tex-conceal.vim",
    config = function()
      vim.o.conceallevel = 1
      vim.g.tex_conceal = "abdmg"
      vim.api.nvim_command("hi Conceal ctermbg=none")
    end
  }, 
  {
    '907th/vim-auto-save',
    config = function()
      -- Set auto-save events
      vim.g.auto_save_events = {"InsertLeave", "TextChanged"}

      -- Enable auto-save for tex file types
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.g.auto_save = 1
          vim.g.auto_save_silent = 1
        end,
      })
    end
  },
  {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        -- Enable live preview
        preview = {
          treesitter = true,
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--ignore-case', -- Make searches case-insensitive
          '--hidden',
          '--fixed-strings', -- This might help with searching for patterns like \text{
        },
      }
    })

    telescope.load_extension("fzf")

    -- Add this function within your Telescope configuration in your init.lua or a specific lua file for configurations
    local function pick_file_and_search()
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      -- Define your files here
      local files = {
        '/home/oddish3/.config/nvim/UltiSnips/tex.snippets',
        '/home/oddish3/Documents/uni/mast-2/notation.tex',
        '/home/oddish3/current_course/UltiSnips',
      }

      pickers.new({}, {
        prompt_title = 'Select a file to search in',
        finder = finders.new_table({
          results = files,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry,
              ordinal = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            require('telescope.builtin').live_grep({ search_dirs = { selection.value } })
          end)
          return true
        end,
      }):find()
    end

    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    keymap.set('n', '<leader>sf', pick_file_and_search, {desc = "Search"})
    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
  end,
},  
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine = require("lualine")
      local lazy_status = require("lazy.status") -- to configure lazy pending updates count

      local colors = {
        blue = "#65D1FF",
        green = "#3EFFDC",
        violet = "#FF61EF",
        yellow = "#FFDA7B",
        red = "#FF4A4A",
        fg = "#c3ccdc",
        bg = "#112638",
        inactive_bg = "#2c3043",
      }
      local my_lualine_theme = {
        normal = {
          a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        insert = {
          a = { bg = colors.green, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        visual = {
          a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        command = {
          a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        replace = {
          a = { bg = colors.red, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        inactive = {
          a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
          b = { bg = colors.inactive_bg, fg = colors.semilightgray },
          c = { bg = colors.inactive_bg, fg = colors.semilightgray },
        },
      }

      -- configure lualine with modified theme
      lualine.setup({
        options = {
          theme = my_lualine_theme,
        },
        sections = {
          lualine_x = {
      {
        lazy_status.updates,
        cond = lazy_status.has_updates,
        color = { fg = "#ff9e64" },
      },
      { check_caps_lock, color = { fg = '#ff9e64' } }, -- Use the function here
      { "fileformat" },
      { "filetype" },
    },
        },
      }) 
    end,
  }
  
})

-- Global settings and mappings
vim.api.nvim_exec([[
    setlocal spell
    set spelllang=en_gb
    inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
]], false)

--vnoremap <C-r> :s/\%V\<\(\w\)\(\w*\)\%V/\u\1\2/g<CR>

-- colourscheme 
vim.cmd[[colorscheme tokyonight]]
vim.cmd[[set clipboard^=unnamed,unnamedplus]]

-- Map the toggle of the quickfix list to a keybinding, e.g., <leader>q, using an inline function
vim.api.nvim_set_keymap('n', '<leader>q', '', {
    noremap = true,
    silent = true,
    callback = function()
        -- Get the list of all windows
        local windows = vim.fn.getwininfo()
        local isQuickfixOpen = false

        -- Check if any window is a quickfix window
        for _, win in pairs(windows) do
            if win.quickfix == 1 then
                isQuickfixOpen = true
                break
            end
        end

        -- Toggle the quickfix window based on its current state
        if isQuickfixOpen then
            vim.cmd('cclose')
        else
            vim.cmd('copen')
        end
    end
})



-- Global settings and mappings
vim.api.nvim_exec([[
    setlocal spell
    set spelllang=en_gb
    inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
]], false)


-- colourscheme 
vim.cmd[[colorscheme tokyonight]]
vim.cmd[[set clipboard^=unnamed,unnamedplus]]

--vim.cmd[[
--augroup SENTENCES
--  au!
--  autocmd InsertCharPre * if search('\v(%^|[.!?]\_s+|\_^\-\s|\_^title\:\s|\n\n|\zs\\item\s+|\zs\--\itemize\{.+\}\s*|\zs\\enumerate\{.+\}\s*|\zs\\section\{.+\}\s*)%#', 'bcnw') != 0 | let v:char = toupper(v:char) | endif
--augroup END
--]]


-- key mappings
--GC
-- Properly map keys to Vimtex commands
vim.api.nvim_set_keymap('n', 'csm', '<Plug>(vimtex-env-change-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dsm', '<Plug>(vimtex-env-delete-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dam', '<Plug>(vimtex-delim-delete-math)', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dim', '<Plug>(vimtex-delim-change-math)', { noremap = true, silent = true })

-- Toggle environment with 'm'
vim.api.nvim_set_keymap('n', 'tsm', '<Plug>(vimtex-env-toggle-math)', { noremap = true, silent = true })

_G.my_custom_mappings = {}

_G.my_custom_mappings.ci_dollar = function()
    vim.cmd('normal ci$')
end

_G.my_custom_mappings.ca_dollar = function()
    vim.cmd('normal ca$')
end

_G.my_custom_mappings.vi_dollar = function()
    vim.cmd('normal vi$')
end

_G.my_custom_mappings.va_dollar = function()
    vim.cmd('normal va$')
end
vim.api.nvim_set_keymap('n', 'cim', ':lua _G.my_custom_mappings.ci_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'cam', ':lua _G.my_custom_mappings.ca_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vim', ':lua _G.my_custom_mappings.vi_dollar()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'vam', ':lua _G.my_custom_mappings.va_dollar()<CR>', { noremap = true, silent = true })



--prime
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--vim.keymap.set("n", "<leader>vwm", function()
--    require("vim-with-me").StartVimWithMe()
--end)
--vim.keymap.set("n", "<leader>svwm", function()
--    require("vim-with-me").StopVimWithMe()
--end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
--vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- global
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gci<Left><Left><Left>]]) -- confirm

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }) --executable 

vim.keymap.set("n", "<leader>vpp", "<cmd>e /home/oddish3/.config/nvim/init.lua<CR>");
--vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

vim.opt.runtimepath:append("/home/oddish3/current_course")



    
