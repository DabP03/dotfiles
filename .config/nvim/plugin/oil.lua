vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" })

require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
	},
	watch_for_changes = true,
	skip_confirm_for_simple_edits = true,
})
vim.keymap.set("n", "\\", "<CMD>Oil --preview<CR>", { desc = "Open parent directory" })
