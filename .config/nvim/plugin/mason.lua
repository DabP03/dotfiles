vim.pack.add({ "https://github.com/williamboman/mason.nvim" })
vim.pack.add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" })

local mason = require("mason")

local mason_tool_installer = require("mason-tool-installer")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_tool_installer.setup({
	ensure_installed = {
    "basedpyright";
    "tinymist";
    "rust-analyzer";
    "clang-format";
    "eslint_d";
    "qmlls";
    "black";
    "clangd";
    "html-lsp";
    "htmlhint";
    "intelephense";
    "jsonlint";
    "lua-language-server";
    "omnisharp";
    "prettier";
    "pylint";
    "shellcheck";
    "stylua";
    "zls";
	},
})
