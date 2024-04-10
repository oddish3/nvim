return {
  "907th/vim-auto-save",
  config = function()
    vim.g.auto_save_events = {"InsertLeave", "TextChanged"}
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        vim.g.auto_save = 1
        vim.g.auto_save_silent = 1
      end,
    })
  end,
}


