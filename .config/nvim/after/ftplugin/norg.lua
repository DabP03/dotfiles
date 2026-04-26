vim.keymap.set(
	"n",
	"<Leader><C-Space>",
	"<Plug>(neorg.pivot.list.toggle)",
	{ desc = "Toggle element under cursor", buffer = true }
)

vim.keymap.set(
	"n",
	"<Leader><CR>",
	"<Plug>(neorg.esupports.hop.hop-link)",
	{ desc = "Jump link under cursor", buffer = true }
)
