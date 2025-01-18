return {
	"numToStr/Comment.nvim",
	config = function()
		require("Comment").setup({
			toggler = {
				line = "<A-c>",
			},
			opleader = {
				line = "<A-c>",
			},
			ignore = "^$",
		})
	end,
}
