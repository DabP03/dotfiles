vim.pack.add({{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" }})

require("catppuccin").setup({
	flavour = "frappe",
	float = {
		transparent = true,
		solid = true,
	},
	show_end_of_buffer = false,
	styles = {
		comments = { "italic" },
		conditionals = { "bold" },
		loops = { "bold" },
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = { "bold" },
		operators = {},
	},
	lsp_styles = {
		inlay_hints = {
			background = false,
		},
	},
	default_integrations = true,
	auto_integrations = true,
	integrations = {
		gitsigns = true,
		treesitter = true,
		mason = true,
		rainbow_delimiters = true,
		which_key = true,
		notify = true,
		telescope = {
			enabled = true,
		},
		blink_cmp = {
			style = "bordered",
		},
        blink_indent = true,
	},
})
vim.cmd.colorscheme("catppuccin")
