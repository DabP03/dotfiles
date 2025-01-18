return {
	"https://github.com/folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local opts = { noremap = true, silent = true }

		-- Trouble
		opts.desc = "Toggle trouble"
		vim.keymap.set("n", "<leader>xx", function()
			require("trouble").toggle()
		end, opts)
		opts.desc = "Toggle workspace diagnostics"
		vim.keymap.set("n", "<leader>xw", function()
			require("trouble").toggle("workspace_diagnostics")
		end, opts)
		opts.desc = "Toggle document diagnostics"
		vim.keymap.set("n", "<leader>xd", function()
			require("trouble").toggle("document_diagnostics")
		end, opts)
		opts.desc = "Toggle quickfix"
		vim.keymap.set("n", "<leader>xq", function()
			require("trouble").toggle("quickfix")
		end, opts)
		opts.desc = "Toggle loclist"
		vim.keymap.set("n", "<leader>xl", function()
			require("trouble").toggle("loclist")
		end, opts)
		opts.desc = "Toggle lsp references"
		vim.keymap.set("n", "gR", function()
			require("trouble").toggle("lsp_references")
		end, opts)
	end,
}
