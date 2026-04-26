local wezterm = require("wezterm")

local config = {
	color_scheme = "Catppuccin Frappe",
	default_cwd = wezterm.home_dir,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	hide_mouse_cursor_when_typing = true,
	enable_kitty_graphics = true,
	font_size = 16,
	enable_wayland = true,
	initial_rows = 30,
	initial_cols = 108,
	window_padding = {
		right = 4,
		left = 4,
		top = 4,
		bottom = 0,
	},
	audible_bell = "Disabled",
	front_end = "WebGpu",
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

local function is_shell(foreground_process_name)
	local shell_names = { "bash", "zsh", "fish", "sh", "ksh", "dash" }
	local process = string.match(foreground_process_name, "[^/\\]+$") or foreground_process_name
	for _, shell in ipairs(shell_names) do
		if process == shell then
			return true
		end
	end
	return false
end

wezterm.on("open-uri", function(window, pane, uri)
	local editor = "nvim"

	if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
		-- We're processing an hyperlink and the uri format should be: file://[HOSTNAME]/PATH[#linenr]
		-- Also the pane is not in an alternate screen (an editor, less, etc)
		local url = wezterm.url.parse(uri)
		if is_shell(pane:get_foreground_process_name()) then
			-- A shell has been detected. Wezterm can check the file type directly
			-- figure out what kind of file we're dealing with
			local success, stdout, _ = wezterm.run_child_process({
				"file",
				"--brief",
				"--mime-type",
				url.file_path,
			})
			if success then
				if stdout:find("directory") then
					pane:send_text(wezterm.shell_join_args({ "cd", url.file_path }) .. "\r")
					pane:send_text(wezterm.shell_join_args({
						"ls",
						"-a",
						"--group-directories-first",
					}) .. "\r")
					return false
				end

				if stdout:find("text") then
					if url.fragment then
						pane:send_text(wezterm.shell_join_args({
							editor,
							"+" .. url.fragment,
							url.file_path,
						}) .. "\r")
					else
						pane:send_text(wezterm.shell_join_args({ editor, url.file_path }) .. "\r")
					end
					return false
				end
			end
		else
			-- No shell detected, we're probably connected with SSH, use fallback command
			local edit_cmd = url.fragment and editor .. " +" .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
			local cmd = '_f="'
				.. url.file_path
				.. '"; { test -d "$_f" && { cd "$_f" ; ls -a -p --hyperlink --group-directories-first; }; } '
				.. '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && '
				.. edit_cmd
				.. "; }; echo"
			pane:send_text(cmd .. "\r")
			return false
		end
	end

	-- without a return value, we allow default actions
end)

return config
