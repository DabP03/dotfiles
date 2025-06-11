vim.api.nvim_create_augroup("python", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = "python",
	pattern = "*.py",
	callback = function()
		vim.fn.setreg("l", 'yiwoprint("": " + ")')
	end,
})
