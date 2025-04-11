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
require 'utils.anki'
require 'utils.autocap'
require 'utils.spell'
require 'utils.wordcount'

require('telescope').setup {
  extensions = {
    zotero = {
      zotero_db_path = '/Users/user/Zotero/zotero.sqlite',
      better_bibtex_db_path = '/Users/user/Zotero/better-bibtex.sqlite',
      zotero_storage_path = '/Users/user/Zotero/storage',
    },
  },
}
require('obsidian.yaml').quote_style = 'single'

vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = 'dimgray', bg = '' })

-- Silence "Is treesitter enabled?" errors
local original_notify = vim.notify
vim.notify = function(msg, ...)
  if msg == 'Error: Is treesitter enabled?' then
    return
  end
  return original_notify(msg, ...)
end

require('leap').create_default_mappings()

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  callback = function()
    vim.bo.syntax = 'oil'
  end,
})

local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match "no parser for 'oil'" then
    return
  end
  notify(msg, ...)
end

vim.keymap.set('v', '<leader>al', function()
  -- Get the start and end of the visual selection
  local _, ls, cs = unpack(vim.fn.getpos "'<")
  local _, le, ce = unpack(vim.fn.getpos "'>")

  -- Choose a list prefix (adjust as needed)
  local bullet = '- ' -- Use "*" for alternative unordered lists or "1. " for ordered

  -- Apply the bullet to each selected line
  vim.cmd(string.format('%d,%ds/^/%s/', ls, le, bullet))

  -- Recalculate list
  vim.cmd 'AutolistRecalculate'
end, { noremap = true, silent = true })
