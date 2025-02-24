return {
  dir = '/Users/user/repos/public/do-stata.nvim', -- Specify the full path to the local repository
  lazy = false, -- This will make the plugin load immediately
  config = function()
    require("do-stata").setup({
      -- Your configuration options here
      stata_ver = "StataMP",
      cell_delimiter = "//%%"
    })
  end
}
