local wezterm = require 'wezterm'

return {
    color_scheme = "Catppuccin Frappe",
    default_cwd = wezterm.home_dir,
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    font_size = 15,
    font = wezterm.font {
        family = 'Fira Code',
        weight = 'Medium',
        harfbuzz_features = {
            'calt=1',
            'clig=1',
            'liga=1',
            'zero',
            'cv01',
            'cv02',
            'cv21',
            'cv29',
            'cv30',
            'ss03',
            'ss04',
            'ss05',
        },
    },
    use_dead_keys = false,
    disable_default_key_bindings = true,
    keys = {
        -- switch to the tab to the left
        {
            key = 'H',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivateTabRelative(-1),
        },
        -- switch to the tab to the right
        {
            key = 'L',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivateTabRelative(1),
        },
        -- split horizontal
        {
            key = '|',
            mods = 'CTRL|SUPER',
            action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        -- split vertical
        {
            key = '-',
            mods = 'CTRL|SUPER',
            action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        -- close active tab
        {
            key = 'Q',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.CloseCurrentTab { confirm = false },
        },
        {
            key = 'Q',
            mods = 'SUPER|SHIFT',
            action = wezterm.action.CloseCurrentPane { confirm = false },
        },
        -- move to the tab to the left
        {
            key = 'H',
            mods = 'CTRL|SHIFT|SUPER',
            action = wezterm.action.MoveTabRelative(-1),
        },
        -- switch to the tab to the right
        {
            key = 'L',
            mods = 'CTRL|SHIFT|SUPER',
            action = wezterm.action.MoveTabRelative(1),
        },
        {
            key = 'h',
            mods = 'CTRL|SUPER',
            action = wezterm.action.ActivatePaneDirection 'Left',
        },
        {
            key = 'j',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Down',
        },
        {
            key = 'k',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Up',
        },
        {
            key = 'l',
            mods = 'CTRL|SUPER',
            action = wezterm.action.ActivatePaneDirection 'Right',
        },
        {
            key = 'H',
            mods = 'SHIFT|SUPER',
            action = wezterm.action.AdjustPaneSize {'Left', 1},
        },
        {
            key = 'J',
            mods = 'SHIFT|SUPER',
            action = wezterm.action.AdjustPaneSize {'Down', 1},
        },
        {
            key = 'K',
            mods = 'SHIFT|SUPER',
            action = wezterm.action.AdjustPaneSize {'Up', 1},
        },
        {
            key = 'L',
            mods = 'SHIFT|SUPER',
            action = wezterm.action.AdjustPaneSize {'Right', 1},
        },
        {
            key = 'T',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.SpawnTab 'DefaultDomain',
        },
        {
            key = 'C',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.CopyTo 'Clipboard',
        },
        {
            key = 'V',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.PasteFrom 'Clipboard',
        },
        {
            key = 'Enter',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ToggleFullScreen,
        },
        {
            key = '=',
            mods = 'CTRL',
            action = wezterm.action.IncreaseFontSize,
        },
        {
            key = '-',
            mods = 'CTRL',
            action = wezterm.action.DecreaseFontSize,
        },
        {
            key = '0',
            mods = 'CTRL',
            action = wezterm.action.ResetFontSize,
        },
        {
            key = 'f',
            mods = 'SUPER',
            action = wezterm.action.Search {CaseSensitiveString=""},
        }

    },
}

