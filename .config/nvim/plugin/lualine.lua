vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" })

require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
	},
})
