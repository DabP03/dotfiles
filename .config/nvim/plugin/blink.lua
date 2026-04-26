vim.pack.add({
	{ src = "https://github.com/Saghen/blink.cmp", version = "v1" },
	{ src = "https://github.com/saghen/blink.download" },
	{ src = "https://github.com/Saghen/blink.pairs", version = "v0.5.0" },
	{ src = "https://github.com/saghen/blink.indent" },
})

require("blink.indent").setup({
	blocked = {
		buftypes = { include_defaults = true },
		filetypes = { include_defaults = true },
	},
	mappings = {
		border = "both",
		object_scope = "ii",
		object_scope_with_border = "ai",
		goto_top = "[i",
		goto_bottom = "]i",
	},
	static = {
		enabled = true,
		char = "▎",
		whitespace_char = nil,
		priority = 1,
		highlights = { "BlinkIndent" },
	},
	scope = {
		enabled = true,
		char = "▎",
		priority = 1000,
		highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' },
		underline = {
			enabled = false,
			highlights = { "BlinkIndentOrangeUnderline", "BlinkIndentVioletUnderline", "BlinkIndentBlueUnderline" },
		},
	},
})
require("blink.pairs").setup({
    mappings = {
      enabled = true,
      cmdline = true,
      disabled_filetypes = {},
      wrap = {
        ['<C-b>'] = 'motion',
        -- move opening pair via motion
        ['<C-S-b>'] = 'motion_reverse',
        -- set to 'treesitter' or 'treesitter_reverse' to use treesitter instead of motions
        -- set to nil, '' or false to disable the mapping
        -- normal_mode = {} <- for normal mode mappings, only supports 'motion' and 'motion_reverse'
      },
      pairs = {},
    },
    highlights = {
      enabled = true,
      cmdline = true,
      groups = { 'BlinkPairsOrange', 'BlinkPairsPurple', 'BlinkPairsBlue' },
      unmatched_group = 'BlinkPairsUnmatched',

      -- highlights matching pairs under the cursor
      matchparen = {
        enabled = true,
        -- known issue where typing won't update matchparen highlight, disabled by default
        cmdline = false,
        -- also include pairs not on top of the cursor, but surrounding the cursor
        include_surrounding = false,
        group = 'BlinkPairsMatchParen',
        priority = 250,
      },
  }
})

require("blink.cmp").setup({
	keymap = {
		preset = "enter",
		["<C-k>"] = { "select_prev", "fallback_to_mappings" },
		["<C-j>"] = { "select_next", "fallback_to_mappings" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = {
			auto_show = false,
		},
		list = {
			selection = {
				preselect = false,
			},
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust" },
})
