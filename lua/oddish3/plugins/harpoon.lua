return {

	'ThePrimeagen/harpoon', lazy = true, 
 	dependencies= { 'nvim-lua/plenary.nvim'},
	config = function ()require("harpoon").setup({

	menu = {
		width = vim.api.nvim_win_get_width(0)-4,
		}
	})
	end
}

