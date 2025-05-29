return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {},
	commit = "29be0919b91fb59eca9e90690d76014233392bef",
	config = function()
		require("ibl").setup({
			indent = {
				smart_indent_cap = true,
			},
			whitespace = {
				remove_blankline_trail = true,
			},
			exclude = {
				buftypes = {
					"help",
					"startify",
					"dashboard",
					"neogitstatus",
					"NvimTree",
					"Trouble",
					"nofile",
					"terminal",
					"prompt",
				},
				filetypes = {
					"lspinfo",
					"packer",
					"checkhealth",
					"help",
					"man",
					"gitcommit",
					"TelescopePrompt",
					"TelescopeResults",
					"''",
				},
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
			},
		})
	end,
}
