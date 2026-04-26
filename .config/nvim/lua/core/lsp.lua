vim.lsp.enable("tinymist")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true)
		end
	end,
})

-- Diagnostics
vim.diagnostic.config({
	virtual_lines = {
		current_line = true,
	},
	update_in_insert = true,
})

-- Color as virtual text
vim.lsp.document_color.enable(true, nil, { style = "virtual" })
