return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
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
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end,
}
