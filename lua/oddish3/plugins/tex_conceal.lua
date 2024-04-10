return {
  "KeitaNakamura/tex-conceal.vim", -- Assuming tex conceal settings are part of your LaTeX setup
  config = function()
    vim.o.conceallevel = 1
    vim.g.tex_conceal = "abdmg"
    vim.api.nvim_command("hi Conceal ctermbg=none")
  end,
}




    


