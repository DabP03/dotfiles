vim.api.nvim_create_augroup("ansi_c", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = "ansi_c",
	pattern = "*.c",
	callback = function()
		vim.fn.setreg("l", 'yiwoprintf("": %", ")F%a')
	end,
})
