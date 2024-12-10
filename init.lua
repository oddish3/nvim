-- NOTE: Throughout this config, some plugins are
-- disabled by default. This is because I don't use
-- them on a daily basis, but I still want to keep
-- them around as examples.
-- You can enable them by changing `enabled = false`
-- to `enabled = true` in the respective plugin spec.
-- Some of these also have the
-- PERF: (performance) comment, which
-- indicates that I found them to slow down the config.
-- (may be outdated with newer versions of the plugins,
-- check for yourself if you're interested in using them)

require 'config.global'
require 'config.lazy'
require 'config.autocommands'
require 'config.redir'

-- Set spell checking to British English
vim.o.spell = true
vim.o.spelllang = 'en_gb'

vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'zz', ':Alpha<CR>', { noremap = true, silent = true })

-- run quartz in terminal
local function run_script_in_terminal(script, args)
  -- Combine the script and arguments into a single command
  local command = script .. " " .. args
  
  -- Open a new terminal buffer at the bottom and run the command
  vim.cmd("botright split | terminal " .. command)
  vim.cmd("resize 10") -- Set terminal buffer height to 10 lines
  
  -- Ensure the terminal doesn't close when the script exits
  vim.cmd("setlocal nonumber norelativenumber")
end

vim.keymap.set("n", "<leader>rp", function()
  run_script_in_terminal("~/repos/scripts/sync.sh", "preview")
end, { desc = "Run sync.sh preview" })
vim.keymap.set("n", "<leader>rbb", function()
  run_script_in_terminal("~/repos/scripts/sync.sh", "build")
end, { desc = "Run sync.sh build" })
vim.keymap.set("n", "<leader>rbp", function()
  run_script_in_terminal("~/repos/scripts/sync.sh", "preview-build")
end, { desc = "Run sync.sh preview-build" })

-- toggle terminal
vim.keymap.set("n", "<leader>tt", function()
  local term_bufnr = vim.fn.bufnr("^term://")
  if term_bufnr ~= -1 then
    -- If the terminal is already open, toggle visibility
    if vim.fn.bufwinnr(term_bufnr) ~= -1 then
      vim.cmd("hide")
    else
      vim.cmd("botright split | b " .. term_bufnr)
      vim.cmd("resize 10") -- Set terminal buffer height to 10 lines
    end
  else
    -- If no terminal exists, create a new one at the bottom
    vim.cmd("botright split | terminal")
    vim.cmd("resize 10") -- Set terminal buffer height to 10 lines
  end
end, { desc = "Toggle terminal at the bottom" })

-- remembers and restores the cursor
local autocmd = vim.api.nvim_create_autocmd
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- Open URL under cursor
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = '*',
  callback = function()
    vim.keymap.set('n', 'gx', function()
      -- Get the word under the cursor
      local word = vim.fn.expand('<cfile>')
      
      -- Check if the word looks like a URL
      if word:match('^http?://') or word:match('^www\\.') then
        -- Use macOS 'open' command to launch in default browser
        vim.fn.system({'open', word})
        print('Opened: ' .. word)
      else
        -- Fallback to Neovim's default gx behavior if not a full URL
        vim.cmd('normal! gx')
      end
    end, { buffer = true })
  end
})

require('stay-centered').setup({
  -- The filetype is determined by the vim filetype, not the file extension. In order to get the filetype, open a file and run the command:
  -- :lua print(vim.bo.filetype)
  skip_filetypes = {lua},
  -- Set to false to disable by default
  enabled = true,
  -- allows scrolling to move the cursor without centering, default recommended
  allow_scroll_move = true,
  -- temporarily disables plugin on left-mouse down, allows natural mouse selection
  -- try disabling if plugin causes lag, function uses vim.on_key
  disable_on_mouse = true,
})

-- git picker
local Path = require('plenary.path')
local scan = require('plenary.scandir')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local entry_display = require('telescope.pickers.entry_display')

-- Define the base directories to search
local git_repos_base = {
  "/Users/user/repos/",
  "/Users/user/.config/nvim/",
  "/Users/user/repos/private/",
  "/Users/user/vault"  -- This will now be checked as a potential git repo itself
}

-- Function to find all git repositories under the specified directories
local function find_git_repos(base_dirs)
  local repos = {}
  for _, dir in ipairs(base_dirs) do
    -- First check if the base directory itself is a git repo
    if Path:new(dir):joinpath(".git"):exists() then
      local repo_name = vim.fn.fnamemodify(dir, ":t")
      local parent_dir = vim.fn.fnamemodify(dir, ":h:t")
      table.insert(repos, {
        path = dir,
        name = repo_name,
        parent = parent_dir
      })
    end

    -- Then scan for subdirectories that are git repos
    local ok, files = pcall(scan.scan_dir, dir, {
      hidden = true,
      depth = 2,
      add_dirs = true,
      respect_gitignore = true
    })
    
    if ok then
      for _, file in ipairs(files) do
        if Path:new(file):joinpath(".git"):exists() then
          local repo_name = vim.fn.fnamemodify(file, ":t")
          local parent_dir = vim.fn.fnamemodify(file, ":h:t")
          table.insert(repos, {
            path = file,
            name = repo_name,
            parent = parent_dir
          })
        end
      end
    end
  end
  return repos
end

-- Create the telescope picker
local function git_repos_picker()
  -- Create displayer for custom formatting
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 30 },  -- repo name
      { width = 20 },  -- parent directory
      { remaining = true },  -- full path
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.name,
      entry.parent,
      { entry.path, "Comment" },
    })
  end

  -- Dynamically find git repositories
  local git_repos = find_git_repos(git_repos_base)

  pickers.new({}, {
    prompt_title = "Git Repositories",
    finder = finders.new_table({
      results = git_repos,
      entry_maker = function(entry)
        return {
          value = entry.path,
          name = entry.name,
          parent = entry.parent,
          path = entry.path,
          display = make_display,
          ordinal = entry.name .. " " .. entry.parent .. " " .. entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      -- Handle repository selection
      local function handle_repo_selection()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        -- Change the working directory
        vim.cmd("cd " .. vim.fn.fnameescape(selection.value))
        
        -- Change the editing session to the new directory
        vim.cmd("tcd " .. vim.fn.fnameescape(selection.value))
        
        -- Notify about the directory change
        vim.notify("Changed to repository: " .. selection.name, vim.log.levels.INFO)
      end

      -- Map enter in insert and normal mode
      map('i', '<CR>', handle_repo_selection)
      map('n', '<CR>', handle_repo_selection)
      
      return true
    end,
  }):find()
end

-- Set up the keymap
vim.keymap.set('n', '<leader>gr', git_repos_picker, {
  desc = "Open Git Repo Picker",
  silent = true
})
