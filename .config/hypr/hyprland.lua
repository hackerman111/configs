-- Converted from hyprland.conf to the native Hyprland Lua configuration API.
-- Target: Hyprland >= 0.55.

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@144",
	position = "0x0",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "ghostty"
local fileManager = "yazi"
local menu = "wofi --show drun"
local browser = "librewolf"
local messenger = "Telegram"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
	)
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
	hl.exec_cmd("command -v dunst >/dev/null && dunst")
	hl.exec_cmd("command -v nm-applet >/dev/null && nm-applet --indicator")
	hl.exec_cmd("command -v blueman-applet >/dev/null && blueman-applet")
	hl.exec_cmd("command -v hypridle >/dev/null && hypridle")
	hl.exec_cmd("hyprpm reload")
	hl.exec_cmd("hyprctl reload")
	hl.exec_cmd("hyprpm list")

	-- Applications on specific workspaces.
	hl.dispatch(hl.dsp.exec_cmd(terminal, { workspace = "10" }))
	hl.dispatch(hl.dsp.exec_cmd(messenger, { workspace = "2" }))
	hl.dispatch(hl.dsp.exec_cmd("obsidian", { workspace = "special:magic silent" }))
	hl.dispatch(hl.dsp.exec_cmd(terminal, { workspace = "1" }))
	hl.dispatch(hl.dsp.exec_cmd(browser, { workspace = "4" }))
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-----------------------
---- NORD PALETTE -----
-----------------------

local nord = {
	nord0 = "2E3440",
	nord1 = "3B4252",
	nord2 = "434C5E",
	nord3 = "4C566A",
	nord4 = "D8DEE9",
	nord5 = "E5E9F0",
	nord6 = "ECEFF4",
	nord7 = "8FBCBB",
	nord8 = "88C0D0",
	nord9 = "81A1C1",
	nord10 = "5E81AC",
	nord11 = "B48EAD",
	nord12 = "BF616A",
	nord13 = "D08770",
	nord14 = "EBCB8B",
	nord15 = "A3BE8C",
}

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 2,

		col = {
			active_border = {
				colors = {
					"rgb(" .. nord.nord8 .. ")",
					"rgb(" .. nord.nord10 .. ")",
					"rgb(" .. nord.nord11 .. ")",
				},
				angle = 45,
			},
			inactive_border = "rgb(" .. nord.nord2 .. ")",
		},

		resize_on_border = true,
		extend_border_grab_area = 8,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,

		shadow = {
			enabled = false,
			range = 0,
			render_power = 1,
			color = "rgba(1f243000)",
			color_inactive = "rgba(1f243000)",
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 2,
			vibrancy = 0.16,
			noise = 0.01,
			contrast = 0.95,
			brightness = 0.9,
		},
	},

	animations = {
		enabled = true,
	},
})

---------------------
---- LAYER RULES ----
---------------------

hl.layer_rule({
	name = "blur-waybar",
	match = { namespace = "waybar" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "blur-wofi",
	match = { namespace = "wofi" },
	blur = true,
	ignore_alpha = 0,
})

hl.layer_rule({
	name = "blur-notifications",
	match = { namespace = "notifications" },
	blur = true,
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("nordBezier", {
	type = "bezier",
	points = { { 0.0, 0.5 }, { 0.5, 1.0 } },
})

hl.curve("linear", {
	type = "bezier",
	points = { { 0, 0 }, { 1, 1 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "nordBezier", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "nordBezier", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "nordBezier", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 7, bezier = "nordBezier" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 7, bezier = "nordBezier" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 20, bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "nordBezier", style = "slidefade 28%" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 6,
	bezier = "nordBezier",
	style = "slidefadevert 35%",
})

-----------------
---- PLUGINS ----
-----------------

hl.config({
	plugin = {
		easymotion = {
			textsize = 18,
			textfont = "JetBrainsMono Nerd Font",
			textcolor = 0xffECEFF4,
			bgcolor = 0xdd2E3440,
			blur = 1,
			blurA = 0.85,
			xray = 0,
			textpadding = "4 8 4 8",
			bordersize = 2,
			bordercolor = "rgba(88C0D0ff) rgba(5E81ACff) 45deg",
			rounding = 8,
			fullscreen_action = "toggle",
			motionkeys = "aoeuidhtnsqjkxbmwvz1234567890",
			motionlabels = "AOEUIDHTNSQJKXBMWVZ1234567890",
			only_special = 1,
		},

		hyprtasking = {
			layout = "grid",
			gap_size = 12,
			bg_color = 0xee2E3440,
			border_size = 2,
			exit_on_hovered = false,
			warp_on_move_window = 1,
			close_overview_on_reload = true,
			drag_button = 0x110,
			select_button = 0x111,

			gestures = {
				enabled = true,
				move_fingers = 3,
				move_distance = 280,
				open_fingers = 4,
				open_distance = 280,
				open_positive = true,
			},

			grid = {
				rows = 4,
				cols = 4,
				loop = false,
				layers = 2,
				loop_layers = false,
				gaps_use_aspect_ratio = true,
			},

			linear = {
				top = false,
				height = 360,
				scroll_speed = 1.0,
				blur = true,
			},
		},
	},
})

--------------------------
---- LAYOUT AND MISC -----
--------------------------

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	master = {
		new_status = "master",
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us, ru",
		kb_variant = "dvorak, diktor",
		kb_model = "",
		kb_options = "grp:alt_shift_toggle",
		kb_rules = "",

		follow_mouse = 1,
		repeat_rate = 35,
		repeat_delay = 250,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
			tap_to_click = true,
			disable_while_typing = true,
			scroll_factor = 0.7,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Launching and session controls.
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("ghostty -e " .. fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + a", hl.dsp.exec_cmd("aimp"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload && pkill -SIGUSR2 waybar"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.dpms({ action = "off" }))

-- Window layout.
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.window.center())

-- Tools from the Hyprland ecosystem.
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprshot -z --mode active -m window"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("command -v hyprpicker >/dev/null && hyprpicker -a"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("/home/papayka/configs/.config/hypr/wall-switcher.sh"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.dpms({ action = "off" }))

-- Scratch workspaces.
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.move({ workspace = "special:hidden" }))
hl.bind(mainMod .. " + F", hl.dsp.workspace.toggle_special("hidden"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.window.move({ workspace = "special:hidden2" }))
hl.bind(mainMod .. " + B", hl.dsp.workspace.toggle_special("hidden2"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move focus with vim-like keys.
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move windows with vim-like keys.
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }), { repeating = true })

-- Resize windows with vim-like keys.
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- Primary workspace bank: 1..10.
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse dragging.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys.
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
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(messenger))

-- Floating window cycle. Both actions are deliberately bound to the same chord,
-- matching the original config.
hl.bind(mainMod .. " + CTRL + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Requires playerctl.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Fixed workspaces on DP-1.
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
for i = 2, 5 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

-- Special workspace gaps.
hl.workspace_rule({ workspace = "special:hidden", gaps_out = 8, gaps_in = 0 })
hl.workspace_rule({ workspace = "special:hidden2", gaps_out = 8, gaps_in = 0 })
hl.workspace_rule({ workspace = "special:magic", gaps_out = 8, gaps_in = 0 })

-- Smart gaps / no border when one tiled window or fullscreen.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "inhibit-idle-while-fullscreen",
	match = { fullscreen = true },
	idle_inhibit = "fullscreen",
})

hl.window_rule({
	name = "picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	pin = true,
	size = { 420, 236 },
})

hl.window_rule({
	name = "file-manager-size",
	match = { class = "^(org.gnome.Nautilus|thunar)$" },
	size = { 900, 620 },
})

hl.window_rule({
	name = "ghostty-opacity",
	match = { class = "^(ghostty)$" },
	opacity = "0.96 0.90",
})

hl.window_rule({
	name = "browser-opacity",
	match = { class = "^(firefox|yandex-browser|yandex-browser-stable|Google-chrome|chromium|librewolf)$" },
	opacity = "0.98 0.94",
})
