return {
  {
    'kyazdani42/nvim-tree.lua', --lazy = true,
    requires = 'kyazdani42/nvim-web-devicons', -- for file icons
    config = function()
      -- Disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      -- Optionally enable 24-bit color
      vim.opt.termguicolors = true

      -- Setup nvim-tree with options
      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
       update_focused_file = {
          enable = true,
          update_root = true,
          ignore_list = {}
        },
      })

      -- Autocmd to open PDF files with Zathura
      vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  	pattern = {"*.pdf"},
  	callback = function()
  	  local cmd = 'nohup zathura ' .. vim.fn.shellescape(vim.fn.expand('%:p')) .. ' &>/dev/null &'
  	  vim.fn.system(cmd)
  	  -- Optionally close the buffer since the file is opened in Zathura
  	  vim.cmd('bd!')
  end,
})
    end
  }
}

