return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local opts = { noremap = true, silent = true }
		harpoon:setup()

		opts.desc = "Harpoon add to list"
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, opts)

		opts.desc = "Harpoon toggle quick menu"
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		opts.desc = "Harpoon select 1"
		vim.keymap.set("n", "<C-1>", function()
			harpoon:list():select(1)
		end)

		opts.desc = "Harpoon select 2"
		vim.keymap.set("n", "<C-2>", function()
			harpoon:list():select(2)
		end)

		opts.desc = "Harpoon select 3"
		vim.keymap.set("n", "<C-3>", function()
			harpoon:list():select(3)
		end)

		opts.desc = "Harpoon select 4"
		vim.keymap.set("n", "<C-4>", function()
			harpoon:list():select(4)
		end)

		-- Toggle previous & next buffers stored within Harpoon list
		opts.desc = "Harpoon previous"
		vim.keymap.set("n", "<C-S-J>", function()
			harpoon:list():prev()
		end)

		opts.desc = "Harpoon next"
		vim.keymap.set("n", "<C-S-K>", function()
			harpoon:list():next()
		end)
	end,
}
