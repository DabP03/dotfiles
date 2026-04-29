local hostname = require("lua.scripts").getHostname()

if hostname == "desktop" then
	hl.monitor({
		output = "DP-2",
		mode = "2560x1440@144",
		position = "0x0",
		scale = "1",
	})

	hl.monitor({
		output = "HDMI-A-2",
		mode = "1920x1080@60",
		position = "-1920x0",
		scale = "1",
	})
else
	hl.monitor({
		output = "eDP-1",
		mode = "1920x1080@60",
		position = "0x0",
		scale = "1",
	})

	hl.monitor({
		output = "HDMI-A-1",
		mode = "1920x1080@60",
		position = "-1920x0",
		scale = "1",
		mirror = "eDP-1",
	})
end

local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "vicinae toggle"
local webBrowser = "zen-browser"

hl.env("HYPRCURSOR_THEME", "catppuccin-frappe-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_SIZE", "20")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GTK_USE_PORTAL", "1")

hl.workspace_rule({ workspace = "spacial:shadowrealm", persistent = true, default = false })
hl.on("hyprland.start", function()
	hl.exec_cmd("qs -d")
	hl.exec_cmd("wl-paste --type text --watch cliphist")
	hl.exec_cmd("wl-paste --type image --watch cliphist")
	hl.exec_cmd("dunst")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("~/.config/hypr/scripts/change_wallpaper.sh 1800")
	hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-frappe-dark-cursors'")
	hl.exec_cmd(fileManager, { workspace = "special:shadowrealm silent" })
	hl.exec_cmd(webBrowser, { workspace = "1 silent" })
	hl.exec_cmd(terminal, { workspace = "2 silent" })
	hl.exec_cmd("strawberry", { workspace = "10 silent" })
	hl.exec_cmd("spotify", { workspace = "10 silent" })
	require("lua.scripts").randomiseWallpaper(1800000)
end)

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 2,
		col = {
			active_border = "rgb(ef9f76)",
			inactive_border = "rgb(292c3c)",
		},
		resize_on_border = false,
		hover_icon_on_border = true,
		allow_tearing = false,
		layout = "scrolling",
	},
})

hl.config({
	decoration = {
		rounding = 16,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = false,
		},
	},
})

hl.config({
	animations = {
		enabled = true,
	},
})

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
		focus_fit_method = true,
	},
})

hl.config({
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})

hl.config({
	input = {
		kb_layout = "pl",
		kb_variant = "",
		kb_model = "",
		kb_options = "caps:escape",
		kb_rules = "",
		follow_mouse = 1,
		repeat_rate = 35,
		repeat_delay = 200,
		touchpad = {
			natural_scroll = true,
		},
	},
})

if hostname == "desktop" then
	hl.config({
		input = {
			accel_profile = "flat",
			sensitivity = 0,
		},
	})
else
	hl.config({
		input = {
			accel_profile = "adaptive",
			sensitivity = 0.2,
		},
	})
end

hl.config({
	group = {
		col = {
			border_active = "rgb(ef9f76)",
			border_inactive = "rgb(303446)",
		},
		groupbar = {
			render_titles = false,
			rounding = 2,
			indicator_height = 2,
			col = {
				active = "rgb(ef9f76)",
				inactive = "rgb(303446)",
			},
		},
	},
})

if hostname == "desktop" then
	for i = 1, 10 do
		hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2" })
		hl.workspace_rule({ workspace = tostring(i + 10), monitor = "HDMI-A-2" })
	end
else
	for i = 1, 10 do
		hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
	end
end

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 4.8, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.8, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", require("lua.scripts").toggleDolphin)
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(webBrowser))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.focus({ workspace = i + 10 }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = i + 10 }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })

hl.bind(
	mainMod .. " + F1",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	mainMod .. " + F2",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	mainMod .. " + F3",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	mainMod .. " + SHIFT + F1",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + F2",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	mainMod .. " + SHIFT + F3",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })

local media = require("lua.playerctl")
hl.bind(mainMod .. " + F9", media.play_pause, { locked = true })
hl.bind(mainMod .. " + F10", media.previous, { locked = true })
hl.bind(mainMod .. " + F11", media.next, { locked = true })
hl.bind(mainMod .. " + SHIFT + F10", media.volume_down, {repeating = true, locked = true})
hl.bind(mainMod .. " + SHIFT + F11", media.volume_up, {repeating = true, locked = true})

hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd("hyprshot -m region --freeze --raw | satty --filename -"),
	{ locked = true }
)
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("hyprshot -m region --freeze --clipboard-only"), { locked = true })

hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "+1" }))

hl.bind(mainMod .. " + CTRL + Left", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "+1" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))

--
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))
--
hl.bind(mainMod .. " + CTRL + SHIFT + Left", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + Right", hl.dsp.window.move({ workspace = "+1" }))
--
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.swap({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.layout("colresize +conf"))

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "Steam Friends",
	match = {
		class = "^(steam)$",
		title = "^(Friends List)$",
	},
	float = true,
})

hl.window_rule({
	name = "Steam Settings",
	match = {
		class = "^(steam)$",
		title = "^(Steam Settings)$",
	},
	float = true,
})

hl.window_rule({
	name = "Hyprland Share Picker",
	match = {
		class = "^(hyprland-share-picker)$",
	},
	float = true,
})

hl.window_rule({
	name = "Satty",
	match = {
		class = "^(com.gabm.satty)$",
	},
	float = true,
})

-- hl.window_rule({
-- 	name = "Strawberry",
-- 	match = {
-- 		class = "^(org.strawberrymusicplayer.strawberry)$",
-- 	},
-- 	workspace = "10 silent",
-- })
--
-- hl.window_rule({
-- 	name = "Spotify",
-- 	match = {
-- 		class = "^(Spotify)$",
-- 	},
-- 	workspace = "10 silent",
-- })

-- Layer rules also return a handle.
local overlayLayerRule = hl.layer_rule({
	name = "no-anim-overlay",
	match = { namespace = "^quickshell$" },
	no_anim = true,
})
overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
