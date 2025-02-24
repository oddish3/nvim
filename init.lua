

require 'config.global'
require 'config.lazy'
require 'config.autocommands'
require 'config.redir'

-- Set spell checking to British English
vim.o.spell = true
vim.o.spelllang = 'en_gb'

vim.api.nvim_set_keymap('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { noremap = true, silent = true })
-- unbind ctrl-k in normal mode
vim.api.nvim_set_keymap('i', '<C-k>', '<nop>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'zz', ':Alpha<CR>', { noremap = true, silent = true })

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

vim.o.mouse = 'a'

require('telescope').setup {
  extensions = {
    zotero = {
      zotero_db_path = "/Users/user/Zotero/zotero.sqlite",
      better_bibtex_db_path = "/Users/user/Zotero/better-bibtex.sqlite",
      zotero_storage_path = "/Users/user/Zotero/storage",
      -- other existing options...
     pdf_opener = "<your custom opener, e.g., zathura, sioyek, etc>"
    }
  }
}

require('utils.anki')
-- unsure whether need these
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_folding_disabled = 1


