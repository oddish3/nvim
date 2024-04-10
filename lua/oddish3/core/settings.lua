-- Global settings and mappings

vim.opt.runtimepath:append("/home/oddish3/current_course")

vim.o.scrolloff = 999

vim.wo.number = true -- Enable line numbers
vim.wo.relativenumber = true -- Enable relative line numbers

vim.o.incsearch = true -- Incremental search
vim.o.ignorecase = true -- Search ignoring case
vim.o.smartcase = true -- Search is case sensitive when uppercase is used

-- colourscheme 
vim.cmd[[colorscheme tokyonight]]
vim.cmd[[set clipboard^=unnamed,unnamedplus]]
 
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 1 and last_pos <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})
--vim.g.nvim_tree_respect_buf_cwd = 1
