vim.pack.add({ "https://github.com/L3MON4D3/LuaSnip" })

require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })

local ls = require("luasnip")

ls.config.setup({
	enable_autosnippets = true,
	region_check_events = "InsertEnter",
	delete_check_events = "InsertLeave",
})
