local wezterm = require("wezterm")

return {
	color_scheme = "Catppuccin Frappe",
	default_cwd = wezterm.home_dir,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	hide_mouse_cursor_when_typing = true,
	font_size = 16,
	enable_wayland = true,
	initial_rows = 30,
	initial_cols = 108,
	audible_bell = "Disabled",
	front_end = "WebGpu",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	font = wezterm.font({
		family = "IosevkaTerm Nerd Font",
		weight = 500,
		harfbuzz_features = {
			"dlig=1",
			"cv07=2",
			"cv10=24",
			"cv36=11",
			"cv42=2",
			"cv59=10",
			"VSAM=1",
			"VSAO=3",
			"VLAB=2",
			"VLAF=2",
			"VLAG=2",
			"VSAG=3",
			"VSAH=3",
			"VSAT=1",
			"VLAD=1",
			"VSAB=3",
		},
	}),
	use_dead_keys = false,
	disable_default_key_bindings = true,
	keys = {
		-- switch to the tab to the left
		{
			key = "H",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		-- switch to the tab to the right
		{
			key = "L",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(1),
		},
		-- switch to the tab to the left
		{
			key = "LeftArrow",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(-1),
		},
		-- switch to the tab to the right
		{
			key = "RightArrow",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateTabRelative(1),
		},
		-- split horizontal
		{
			key = "\\",
			mods = "CTRL|SUPER",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		-- split vertical
		{
			key = "-",
			mods = "CTRL|SUPER",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- close active tab
		{
			key = "Q",
			mods = "CTRL|SHIFT",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{
			key = "Q",
			mods = "SUPER|SHIFT",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		-- move to the tab to the left
		{
			key = "H",
			mods = "CTRL|SHIFT|SUPER",
			action = wezterm.action.MoveTabRelative(-1),
		},
		-- switch to the tab to the right
		{
			key = "L",
			mods = "CTRL|SHIFT|SUPER",
			action = wezterm.action.MoveTabRelative(1),
		},
		{
			key = "h",
			mods = "CTRL|SUPER",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "CTRL|SUPER",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "H",
			mods = "SHIFT|SUPER",
			action = wezterm.action.AdjustPaneSize({ "Left", 1 }),
		},
		{
			key = "J",
			mods = "SHIFT|SUPER",
			action = wezterm.action.AdjustPaneSize({ "Down", 1 }),
		},
		{
			key = "K",
			mods = "SHIFT|SUPER",
			action = wezterm.action.AdjustPaneSize({ "Up", 1 }),
		},
		{
			key = "L",
			mods = "SHIFT|SUPER",
			action = wezterm.action.AdjustPaneSize({ "Right", 1 }),
		},
		{
			key = "T",
			mods = "CTRL|SHIFT",
			action = wezterm.action.SpawnTab("DefaultDomain"),
		},
		{
			key = "C",
			mods = "CTRL|SHIFT",
			action = wezterm.action.CopyTo("Clipboard"),
		},
		{
			key = "V",
			mods = "CTRL|SHIFT",
			action = wezterm.action.PasteFrom("Clipboard"),
		},
		{
			key = "Enter",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "=",
			mods = "CTRL",
			action = wezterm.action.IncreaseFontSize,
		},
		{
			key = "-",
			mods = "CTRL",
			action = wezterm.action.DecreaseFontSize,
		},
		{
			key = "0",
			mods = "CTRL",
			action = wezterm.action.ResetFontSize,
		},
		{
			key = "f",
			mods = "SUPER",
			action = wezterm.action.Search({ CaseSensitiveString = "" }),
		},
		{
			key = "P",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateCommandPalette,
		},
		{
			key = "Y",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateCopyMode,
		},
	},
}
