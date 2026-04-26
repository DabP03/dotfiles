return {
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
				closingBraceHints = {
					enable = true,
					minLines = 1,
				},
				bindingModeHints = {
					enable = true,
				},
				lifetimeElisionHints = { enable = "skip_trivial" },
			},
		},
	},
}
