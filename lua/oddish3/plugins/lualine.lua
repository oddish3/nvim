return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "kyazdani42/nvim-web-devicons" }, -- Assuming you want icons support
  config = function()
    -- Define the check_caps_lock function directly inside the config function
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
    
	local function getWords()
  		return tostring(vim.fn.wordcount().words)
	end

    require("lualine").setup({
      options = {
        -- Use the Tokyonight theme included with lualine
        theme = 'tokyonight',
        globalstatus = true,
        -- Other options...
      },
      sections = {
        -- Place the check_caps_lock function in the desired section
        lualine_x = { 
          'filetype',
          { check_caps_lock, color = { fg = '#ff9e64' } }, -- Use the function here
	{ getWords },
        },
        -- Other sections as per your current configuration...
      },
      -- Additional lualine configuration settings...
    })
  end,
}

