vim.api.nvim_create_augroup("bash", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = "bash",
	pattern = "*.sh",
	callback = function()
		vim.fn.setreg("l", 'yiwoecho "": ${"}"')
	end,
})
