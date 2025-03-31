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
require('leap').create_default_mappings()
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

-- Silence "Is treesitter enabled?" errors
local original_notify = vim.notify
vim.notify = function(msg, ...)
  if msg == 'Error: Is treesitter enabled?' then
    return
  end
  return original_notify(msg, ...)
end





