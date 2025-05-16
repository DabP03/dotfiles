return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local opts = {
			noremap = true,
			silent = true,
		}

		local keymap_set = function(mode, keybind, action, desc) --[[ vim.keymap ]]
			opts.desc = desc
			vim.keymap.set(mode, keybind, action, opts)
		end

		local on_attach = function(client, bufnr)
			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true)
			end
			opts.buffer = bufnr

			keymap_set("n", "<leader>sR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
			keymap_set("n", "<leader>gD", vim.lsp.buf.declaration, "Go to declaration")
			keymap_set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
			keymap_set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
			keymap_set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
			keymap_set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
			keymap_set("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
			keymap_set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
			keymap_set("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
			keymap_set("n", "K", vim.lsp.buf.hover, "Show documentation for what is under cursor")
			keymap_set("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		lspconfig["clangd"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "c", "cpp", "h", "hpp" },
		})

		-- configure html server
		lspconfig["html"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure css server
		lspconfig["cssls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure python server
		lspconfig["pyright"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure ts server
		lspconfig["ts_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			root_dir = require("lspconfig").util.root_pattern("package.json"),
			single_file_support = false,
			settings = {
				javascript = {
					format = {
						semicolons = "insert",
					},
					suggest = {
						completeFunctionCalls = true,
					},
				},
			},
		})

		lspconfig["denols"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				lint = true,
				unstable = true,
			},
			root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
		})

		-- configure rust analyzer
		lspconfig["rust_analyzer"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { "rust" },
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						target = "arm-unknown-linux-gnueabihf",
						allTargets = false,
					},
					inlayHints = {
						parameterHints = { enable = true },
						typeHints = { enable = true },
						chainingHints = { enable = true },
						closingBraceHints = { enable = true },
						bindingModeHints = {
							enable = true,
						},
						lifetimeElisionHints = { enable = "skip_trivial" },
					},
				},
			},
		})

		-- configure lua server (with special settings)
		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		lspconfig["jsonls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["bashls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["asm_lsp"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
	end,
}
