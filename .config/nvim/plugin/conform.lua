vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		rust = { "rustfmt" },
		javascript = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		c = { "clang-format" },
		bash = { "beautysh" },
		assembly = { "asmfmt" },
		typst = { "prettypst" },
		latex = { "tex-fmt" },
	},
})
