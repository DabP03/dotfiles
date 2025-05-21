vim.api.nvim_create_augroup("rust", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = "rust",
	pattern = "*.rs",
	callback = function()
		vim.fn.setreg("l", 'yiwoprintln!("": {}", ")')
	end,
})
