local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome library
local gears = require("gears") --Utilities such as color parsing and objects
local awful = require("awful") --Everything related to window managment
require("awful.autofocus")
awful.util.spawn("xprop -root -f _NET_NUMBER_OF_DESKTOPS 32c -set _NET_NUMBER_OF_DESKTOPS 5")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
beautiful.useless_gap = 19
-- Notification library
local naughty = require("naughty")
naughty.config.defaults["icon_size"] = 100

local lain = require("lain")
local freedesktop = require("freedesktop")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

-- Handle runtime errors after startup
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

run_once({ "unclutter -root" }) -- entries must be comma-separated

beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")
local modkey = "Mod4"
local altkey = "Mod1"
local ctrlkey = "Control"
local terminal = "kitty"
local mediaplayer = "mpv"

-- awesome variables
awful.util.terminal = terminal
--awful.util.tagnames = {  " ", " ", " ", " ", " ", " ", " ", "  ", "  ", " "  }
awful.util.tagnames = { "  ", "   ", "   ", "   ", "   ", " " }
awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	--awful.layout.suit.tile.left,
	--awful.layout.suit.tile.bottom,
	--awful.layout.suit.tile.top,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.sw,
	--awful.layout.suit.corner.se,
	--lain.layout.cascade,
	--lain.layout.cascade.tile,
	--lain.layout.centerwork,
	--lain.layout.centerwork.horizontal,
	--lain.layout.termfair,
	--lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		local instance = nil

		return function()
			if instance and instance.wibox.visible then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = 250 } })
			end
		end
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = 2
lain.layout.cascade.tile.offset_y = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

local myawesomemenu = {
	{
		"hotkeys",
		function()
			return false, hotkeys_popup.show_help
		end,
	},
	{ "manual", terminal .. " -e 'man awesome'" },
	{ "edit config", "nvim ~/.config/awesome/rc.lua" },
	{ "arandr", "arandr" },
	{ "restart", awesome.restart },
}

awful.util.mymainmenu = freedesktop.menu.build({
	icon_size = beautiful.menu_height or 16,
	before = {
		{ "Awesome", myawesomemenu, beautiful.awesome_icon },
		--{ "Atom", "atom" },
		-- other triads can be put here
	},
	after = {
		{ "Terminal", terminal },
		{
			"Log out",
			function()
				awesome.quit()
			end,
		},
		{ "Sleep", "systemctl suspend" },
		{ "Restart", "systemctl reboot" },
		{ "Reboot", "systemctl poweroff" },
		-- other triads can be put here
	},
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it

local soundDir = "/opt/dtos-sounds/" -- The directory that has the sound files

local startupSound = soundDir .. "startup-01.mp3"
local shutdownSound = soundDir .. "shutdown-01.mp3"
local dmenuSound = soundDir .. "menu-01.mp3"

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)
-- Create a
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)

root.buttons(my_table.join(
	awful.button({}, 3, function()
		awful.util.mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))

-- Volume --

local function get_volume_icon(vol, muted)
	local iDIR = os.getenv("HOME") .. "/.config/swaync/icons"
	if muted then
		return iDIR .. "/volume-mute.png"
	else
		local v = tonumber(vol) or 0
		if v <= 30 then
			return iDIR .. "/volume-low.png"
		elseif v <= 60 then
			return iDIR .. "/volume-mid.png"
		else
			return iDIR .. "/volume-high.png"
		end
	end
end

-- Send volume notification as in your shell script, with a wider notification.
local function notify_volume()
	awful.spawn.easy_async_with_shell("amixer get Master", function(stdout)
		local vol = string.match(stdout, "(%d?%d?%d)%%")
		local status = string.match(stdout, "%[(%a+)%]")
		local muted = (status and status:lower() == "off")
		local icon = get_volume_icon(vol, muted)

		if muted then
			awful.spawn.with_shell(
				string.format(
					"notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif -h string:x-dunst:geometry:400x100 -i '%s' ' Volume:' 'Muted'",
					icon
				)
			)
		else
			awful.spawn.with_shell(
				string.format(
					"notify-send -e -u low -h int:value:%s -h string:x-canonical-private-synchronous:volume_notif -h string:x-dunst:geometry:400x100 -i '%s' ' Volume Level:' ' %s%%'",
					vol,
					icon,
					vol
				)
			)
			-- Optionally, if you want to play a sound:
			-- awful.spawn.with_shell(os.getenv("HOME") .. "/.config/hypr/scripts/Sounds.sh --volume")
		end
	end)
end

-- Send mute toggle notification with wider geometry.
local function notify_mute_toggle()
	awful.spawn.easy_async_with_shell("amixer get Master", function(stdout)
		local vol = string.match(stdout, "(%d?%d?%d)%%") or "0"
		local status = string.match(stdout, "%[(%a+)%]")
		local muted = (status and status:lower() == "off")
		local iDIR = os.getenv("HOME") .. "/.config/swaync/icons"

		if muted then
			awful.spawn.with_shell(
				string.format(
					"notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif -h string:x-dunst:geometry:400x100 -i '%s' ' Volume:' 'Muted'",
					iDIR .. "/volume-mute.png"
				)
			)
		else
			notify_volume()
		end
	end)
end

-- AwesomeWM keybindings with fixed 5% steps and wider notifications.

globalkeys = my_table.join(

	awful.key({}, "XF86AudioRaiseVolume", function()
		os.execute(string.format("amixer -q set %s 5%%+", beautiful.volume.channel or "Master"))
		notify_volume()
	end, { description = "increase volume and show notification", group = "custom widgets" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		os.execute(string.format("amixer -q set %s 5%%-", beautiful.volume.channel or "Master"))
		notify_volume()
	end, { description = "decrease volume and show notification", group = "custom widgets" }),

	awful.key({}, "XF86AudioMute", function()
		os.execute(
			string.format(
				"amixer -q set %s toggle",
				beautiful.volume.togglechannel or beautiful.volume.channel or "Master"
			)
		)
		notify_mute_toggle()
		if beautiful.volume.update then
			beautiful.volume.update()
		end
	end, { description = "toggle mute and show notification", group = "custom widgets" }),
	-- Multimedia keys
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("playerctl play-pause")
	end, { description = "toggle play/pause", group = "media" }),

	awful.key({}, "XF86AudioNext", function()
		awful.spawn("playerctl next")
	end, { description = "next track", group = "media" }),

	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("playerctl previous")
	end, { description = "previous track", group = "media" }),
	-- Launcher
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "Launch terminal", group = "awesome" }),
	awful.key({ modkey }, "f", function()
		awful.spawn("dolphin")
	end, { description = "Launch fm", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "s", function()
		awful.spawn("flameshot gui")
	end, { description = "Take a screenshot with Flameshot", group = "hotkeys" }),
	awful.key({ modkey }, "s", function()
		awful.spawn("flameshot full")
	end, { description = "Take a screenshot with Flameshot", group = "hotkeys" }),
	awful.key({ altkey }, "m", function()
		awful.spawn("notion-calendar-electron")
	end, { description = "Launch calendar", group = "hotkeys" }),
	awful.key({ altkey }, "n", function()
		awful.spawn("notion-app")
	end, { description = "Launch Notion", group = "hotkeys" }),
	awful.key({ modkey }, "q", function()
		awful.spawn("rquickshare")
	end, { description = "Launch quickshare", group = "hotkeys" }),
	awful.key({ modkey }, "v", function()
		awful.spawn("code")
	end, { description = "Launch VSCode", group = "hotkeys" }),
	awful.key({ modkey }, "e", function()
		awful.spawn("kcolorchooser")
	end, { description = "Launch kcolor", group = "hotkeys" }),
	awful.key({ modkey }, "b", function()
		awful.spawn("brave-browser")
	end, { description = "Launch brave", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "Reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", function()
		awful.spawn.with_shell("dm-logout")
	end, { description = "Quit awesome", group = "awesome" }),
	--awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "w", function()
		awful.util.mymainmenu:show()
	end, { description = "Show main menu", group = "awesome" }),
	awful.key({ altkey }, "e", function() -- Mod1 = Alt key
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/toggle_polybar.sh")
	end),
	awful.key({ modkey }, "r", function() -- Mod1 = Alt key
		awful.spawn.with_shell("pkill polybar && $HOME/.config/polybar/lauch.sh &")
	end),
	awful.key({ modkey, "Shift" }, "c", function() -- Mod1 = Alt key
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/KillActive_process.sh &")
	end),
	awful.key({ altkey, "Control" }, "p", function()
		awful.spawn.with_shell("wlogout")
	end),
	awful.key({ altkey, "Control" }, "Delete", function()
		awful.spawn.with_shell("awesome-client 'awesome.quit()'")
	end),
	-- Run launcher
	awful.key({ altkey }, "space", function()
		awful.util.spawn("dm-run")
	end, { description = "Run launcher", group = "hotkeys" }),

	-- Rofi launcher's
	awful.key({ altkey }, "f", function()
		awful.spawn("rofi -show drun -modi drun,run,window,filebrowser")
	end, { description = "launch rofi", group = "launcher" }),
	awful.key({ altkey }, "v", function()
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/ClipManager.sh")
	end, { description = "launch rofi-clip", group = "launcher" }),
	awful.key({ altkey }, "s", function()
		awful.spawn.with_shell("$HOME/.config/eww/dashboard/launch_dashboard")
	end, { description = "launch rofi-clip", group = "launcher" }),
	awful.key({ modkey }, "x", function()
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/WallpaperSelect.sh")
	end, { description = "launch rofi-Wall", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "m", function()
		awful.spawn.with_shell("$HOME/.config/awesome/scripts/RofiBeats.sh")
	end, { description = "launch rofi-beats", group = "launcher" }),

	-- By direction client focus
	awful.key({ altkey }, "j", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus down", group = "client" }),
	awful.key({ altkey }, "k", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus up", group = "client" }),
	awful.key({ altkey }, "h", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus left", group = "client" }),
	awful.key({ altkey }, "l", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "Focus right", group = "client" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey }, ".", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey }, ",", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ ctrlkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- On the fly ement useless gaps", group = "tag" }),
	awful.key({ altkey, ctrlkey }, "k", function()
		lain.util.useless_gaps_resize(-1)
	end, { description = "decrement useless gaps", group = "tag" }),

	-- Resize window by vim motion
	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey }, "k", function()
		awful.client.incwfact(0.05)
	end, { description = "increase vertical factor", group = "layout" }),
	awful.key({ modkey }, "j", function()
		awful.client.incwfact(-0.05)
	end, { description = "decrease vertical factor", group = "layout" }),

	-- Change layout
	awful.key({ modkey, "Shift" }, "Up", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "Down", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients by ", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients by", group = "layout" }),

	awful.key({ modkey, ctrlkey }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, ctrlkey }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey, "Shift" }, "Tab", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	-- Dropdown application
	awful.key({ modkey }, "F12", function()
		awful.screen.focused().quake:toggle()
	end, { description = "dropdown application", group = "super" }),

	-- Brightness
	-- Brightness keybindings with notifications
	awful.key({}, "XF86MonBrightnessUp", function()
		-- Increase brightness by 5%
		awful.spawn("brightnessctl set +5%")
		-- Get current brightness and maximum brightness, then compute percentage
		awful.spawn.easy_async_with_shell("brightnessctl get", function(current_stdout)
			local current = tonumber(current_stdout) or 0
			awful.spawn.easy_async_with_shell("brightnessctl max", function(max_stdout)
				local max_val = tonumber(max_stdout) or 1
				local percent = math.floor((current / max_val) * 100 + 0.5)
				if percent < 5 then
					percent = 5
				end
				local brightness_icon = os.getenv("HOME") .. "/.config/swaync/icons/brightness.png"
				awful.spawn.with_shell(
					string.format(
						"notify-send -e -u low -h int:value:%s -h string:x-dunst:geometry:600x100 -i '%s' 'Brightness:' ' %s%%'",
						percent,
						brightness_icon,
						percent
					)
				)
			end)
		end)
	end, { description = "Increase brightness", group = "custom" }),

	awful.key({}, "XF86MonBrightnessDown", function()
		-- Decrease brightness by 5%
		awful.spawn("brightnessctl set 5%-")
		awful.spawn.easy_async_with_shell("brightnessctl get", function(current_stdout)
			local current = tonumber(current_stdout) or 0
			awful.spawn.easy_async_with_shell("brightnessctl max", function(max_stdout)
				local max_val = tonumber(max_stdout) or 1
				local percent = math.floor((current / max_val) * 100 + 0.5)
				if percent < 5 then
					percent = 5
				end
				local brightness_icon = os.getenv("HOME") .. "/.config/swaync/icons/brightness.png"
				awful.spawn.with_shell(
					string.format(
						"notify-send -e -u low -h int:value:%s -h string:x-dunst:geometry:100x100000 -h string:x-canonical-private-synchronous:brightness_notif -i '%s' 'Brightness:' ' %s%%'",
						percent,
						brightness_icon,
						percent
					)
				)
			end)
		end)
	end, { description = "Decrease brightness", group = "custom" }),
	-- ALSA volume control

	-- Copy clipboard to primary (gtk to terminals)
	awful.key({ modkey }, "v", function()
		awful.spawn.with_shell("xsel -b | xsel")
	end, { description = "copy gtk to terminal", group = "hotkeys" }),
	awful.key({ altkey, "Shift" }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" })
	--]]
)

-- dropdown
-- Scratchpad

local scratchpads = {}

-- Helper: compute a coordinate given opts.value, total size, window size, start offset, and gap
local function compute_pos(value, total, size, start, gap)
	if type(value) == "number" then
		return start + value
	elseif value == "left" or value == "top" then
		return start + gap
	elseif value == "right" or value == "bottom" then
		return start + total - size - gap
	else
		-- "center" or nil
		return start + (total - size) / 2
	end
end

function make_scratchpad(name, spawn_cmd, opts)
	opts = opts or {}
	opts.width = opts.width or 1050
	opts.height = opts.height or 650
	opts.class = opts.class or name
	opts.gap = opts.gap or 20

	-- Toggle function
	local function toggle()
		local s = awful.screen.focused()
		local tag = s.selected_tag
		local sp = scratchpads[name]

		if sp and sp.valid then
			if not sp.minimized and sp:isvisible() then
				sp.minimized = true
			else
				sp.minimized = false
				sp:move_to_tag(tag)
				sp:raise()
				client.focus = sp
			end
		else
			awful.spawn(spawn_cmd)
		end
	end

	-- When a new client appears, configure it if it matches our scratchpad
	client.connect_signal("manage", function(c)
		if c.class == opts.class then
			scratchpads[name] = c
			c.floating = true
			c.ontop = true
			c.skip_taskbar = true
			c.width = opts.width
			c.height = opts.height

			local wa = c.screen.workarea
			-- figure out x,y
			local x = compute_pos(opts.x, wa.width, opts.width, wa.x, opts.gap)
			local y = compute_pos(opts.y, wa.height, opts.height, wa.y, opts.gap)

			c.x = x
			c.y = y

			if wa.selected_tag then
				c:move_to_tag(wa.selected_tag)
			end
		end
	end)

	-- Keep it on your current tag
	tag.connect_signal("property::selected", function(t)
		local sp = scratchpads[name]
		if sp and sp.valid and not sp.minimized then
			sp:move_to_tag(t)
		end
	end)

	return toggle
end
-- Create toggles
local toggle_pavcontrol = make_scratchpad("pavucontrol", "pavucontrol", {
	width = 800,
	height = 500,
	class = "pavucontrol",
	y = "bottom",
	gap = 230, -- 80px from the top edge
	-- x=nil → defaults to "center"
})
local toggle_resources = make_scratchpad("resources", "flatpak run net.nokyan.Resources", {
	width = 820,
	height = 550,
	class = "resources",
	y = "bottom",
	gap = 230,
	-- x is nil, so it will center horizontally
})
local toggle_clock = make_scratchpad("kclock", "kclock", {
	width = 350,
	height = 450,
	class = "kclock",
	y = "bottom",
	gap = 230,
	-- x is nil, so it will center horizontally
})
local toggle_kdeconnect = make_scratchpad("kdeconnect.app", "kdeconnect-app", {
	width = 450,
	height = 350,
	class = "kdeconnect.app",
	y = "bottom",
	gap = 230,
	-- x is nil, so it will center horizontally
})
local toggle_cal = make_scratchpad("Qalculate-gtk", "qalculate-gtk", {
	width = 350,
	height = 520,
	class = "Qalculate-gtk",
	y = "bottom",
	gap = 80,
	-- x is nil, so it will center horizontally
})
local toggle_terminal = make_scratchpad("scratchkitty", "kitty --class scratchkitty", {
	width = 1050,
	height = 650,
	class = "scratchkitty",
	y = 15, -- gap from top
	-- x will be centered automatically
})
local toggle_whatsie = make_scratchpad("whatsie", "flatpak run com.ktechpit.whatsie", {
	width = 1050,
	height = 650,
	class = "WhatSie",
	y = 15, -- gap from top
	-- x will be centered automatically
})

-- Bind them to keys
globalkeys = gears.table.join(
	globalkeys, -- keep previously defined globalkeys
	awful.key({ "Control" }, "Return", toggle_terminal, { description = "...", group = "scratchpads" }),
	awful.key({ altkey }, "d", toggle_pavcontrol, { description = "...", group = "scratchpads" }),
	awful.key({ altkey }, "g", toggle_resources, { description = "...", group = "scratchpads" }),
	awful.key({ altkey }, "c", toggle_cal, { description = "...", group = "scratchpads" }),
	awful.key({ altkey }, "w", toggle_clock, { description = "...", group = "scratchpads" }),
	awful.key({ modkey }, "w", toggle_whatsie, { description = "...", group = "scratchpads" }),
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("playerctl play-pause")
	end),
	awful.key({}, "XF86AudioNext", function()
		awful.spawn("playerctl next")
	end),
	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("playerctl previous")
	end),
	awful.key({ altkey }, "p", toggle_kdeconnect, { description = "...", group = "scratchpads" })
)

clientkeys = my_table.join(
	awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }),
	awful.key({ modkey }, "space", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey }, "c", function(c)
		c:kill()
	end, { description = "close", group = "hotkeys" }),
	awful.key({ modkey }, "t", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
	awful.key({ modkey, ctrlkey }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey, "Shift" }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "maximize", group = "client" })
)

-- Bind tags to shortcut's
-- Define letter shortcuts for workspaces 1, 2, and 3
local letterKeys = { "i", "o", "p" }

for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end

	-- Adjusting keys for tags 4, 5, and 6 to map to 7, 8, and 9
	local adjusted_key = i
	if i >= 4 and i <= 6 then
		adjusted_key = i + 3
	end

	-- Standard numeric shortcuts for all workspaces (using modkey + number keys)
	globalkeys = my_table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. adjusted_key + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modkey, ctrlkey }, "#" .. adjusted_key + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. adjusted_key + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, ctrlkey, "Shift" }, "#" .. adjusted_key + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)

	-- Additional letter shortcuts for workspaces 1, 2, and 3 (i, o, p)
	if i <= 3 then
		local letter_descr = { description = "tag #" .. i, group = "tag" }
		globalkeys = my_table.join(
			globalkeys,
			-- View tag only.
			awful.key({ modkey }, letterKeys[i], function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end, letter_descr),
			-- Toggle tag display.
			awful.key({ modkey, ctrlkey }, letterKeys[i], function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end, letter_descr),
			-- Move client to tag.
			awful.key({ modkey, "Shift" }, letterKeys[i], function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end, letter_descr),
			-- Toggle tag on focused client.
			awful.key({ modkey, ctrlkey, "Shift" }, letterKeys[i], function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end, letter_descr)
		)
	end
end

-- Resize the window by mouse
clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			size_hints_honor = false,
		},
	},

	-- Titlebars
	{ rule_any = { type = { "dialog", "normal" } }, properties = { titlebars_enabled = false } },

	-- Set applications to always map on the tag 1 on screen 1.
	-- find class or role via xprop command
	--{ rule = { class = browser1 },
	--properties = { screen = 1, tag = awful.util.tagnames[1] } },

	--{ rule = { class = editorgui },
	--properties = { screen = 1, tag = awful.util.tagnames[2] } },

	--{ rule = { class = "Geany" },
	--properties = { screen = 1, tag = awful.util.tagnames[2] } },

	-- Set applications to always map on the tag 3 on screen 1.
	--{ rule = { class = "Inkscape" },
	--properties = { screen = 1, tag = awful.util.tagnames[3] } },

	-- Set applications to always map on the tag 4 on screen 1.
	--{ rule = { class = "Gimp" },
	--properties = { screen = 1, tag = awful.util.tagnames[4] } },

	-- Set applications to be maximized at startup.
	-- find class or role via xprop command

	-- Rules to open a app in sepcific tag

	{ rule = { class = "autokey-qt" }, properties = { tag = "   " } },
	{ rule = { class = "vlc" }, properties = { tag = "   " } },

	{ rule = { class = "Rquickshare" }, properties = { floating = true } },
	--{ rule = { class = "WhatSie" }, properties = { floating = true, width = 950, height = 650, x = 0, y = 17 } },

	-- Brave pop-up dialogs (e.g., file chooser)
	-- Float and center kdialog popups (used by Brave and other apps)
	{
		rule = { class = "kdialog" },
		properties = {
			floating = true,
			ontop = true,
			placement = awful.placement.centered,
		},
	},
	{
		rule = { class = "Brave-browser", instance = "crx_nngceckbapebfimnlniiiahkandclblb" },
		properties = {
			floating = true,
			ontop = true,
		},
	},
	{
		rule = { class = "polybar" }, -- Use the correct WM_CLASS for Polybar
		properties = { border_width = 9 },
	},
	{ rule = { class = "Gimp*", role = "gimp-image-window" }, properties = { maximized = true } },

	{ rule = { class = "inkscape" }, properties = { maximized = true } },

	{ rule = { class = mediaplayer }, properties = { maximized = true } },

	{ rule = { class = "Vlc" }, properties = { maximized = true } },

	{ rule = { class = "VirtualBox Manager" }, properties = { maximized = false } },

	--{ rule = { class = "VirtualBox Machine" }, properties = { maximized = true } },
	{
		rule = { class = "VirtualBox Machine", name = "home ais [Running] - Oracle VirtualBox" },
		properties = {
			tag = function(c)
				for _, t in ipairs(c.screen.tags) do
					if t.name == " " then
						return t
					end
				end
				return c.screen.tags[1]
			end,
			maximized = false,
		},
	},
	{ rule = { class = "Xfce4-settings-manager" }, properties = { floating = false } },

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"blueman-manager",
				"copyq", -- Includes session name in class.
			},
			class = {
				"Blueberry",
				"Qalculate-gtk",
				"kcolorchooser",
				"Blueman-manager",
			},
		},
		properties = { floating = true, ontop = true },
		callback = function(c)
			c:geometry({ width = 550, height = 440 })
			awful.placement.centered(c, { honor_workarea = true })
		end,
	},
}

table.insert(awful.rules.rules, floating_rule)
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons = my_table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, { size = 21 }):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = true })
end)

-- No border for maximized clients
function border_adjust(c)
	if c.maximized then -- no borders if only 1 client visible
		c.border_width = 0
	elseif #awful.screen.focused().clients > 1 then
		c.border_width = beautiful.border_width
		c.border_color = beautiful.border_focus
	end
end

client.connect_signal("focus", border_adjust)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- Gaps --
awful.screen.padding(awful.screen.focused(), { left = 1, right = 1, top = 2, bottom = 1 })

-- Set default notification settings
naughty.config.defaults.timeout = 3 -- Timeout for notifications
naughty.config.defaults.position = "top_right" -- Positioning at the bottom-right corner

-- Set notification theme (background and foreground colors)
naughty.config.presets.normal = {
	font = "Monospace 10",
	border_width = 1,
	shape = naughty.config.presets.normal.shape,
	opacity = 0.9, -- 10% transparency
	width = 330, -- Fixed width
}

-- Position notifications with padding
naughty.config.padding = 30 -- padding for notifications

--Auto Start
--awful.spawn.with_shell(soundplayer .. startupSound)
awful.spawn.with_shell("lxsession")
awful.spawn.with_shell("picom --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("nm-applet")
awful.spawn.with_shell("volumeicon")
awful.spawn.with_shell("killall conky && conky -c $HOME/.config/conky/awesome/" .. "doom-one" .. "-01.conkyrc")
--awful.spawn.with_shell("xsettingsd &")
awful.spawn.with_shell("numlockx on")
awful.spawn.with_shell("nm-applet --indicator &")
awful.spawn.with_shell("blueman-applet &")
awful.spawn.with_shell("greenclip daemon  &")
awful.spawn.with_shell("autokey-qt &")
awful.spawn.with_shell("kdeconnectd &")
--awful.spawn.with_shell("swww-daemon --format xrgb")
awful.spawn.with_shell("~/.fehbg")
awful.spawn.with_shell(
	"pgrep -f pulseaudio_event_listener.sh > /dev/null || && ~/.config/polybar/scripts/pulseaudio_event_listener.sh &"
)
awful.spawn.with_shell("~/scripts/startups/connect_realmebuds.sh &")
awful.spawn.with_shell("~/.config/polybar/lauch.sh &")
--awful.spawn.with_shell("~/.config/awesome/scripts/auto-music-switcher.sh &")
--awful.spawn.with_shell("rclone mount Shri77: ~/Shri77/") --Interchange escape with caps
--awful.spawn.with_shell("xdotool key Num_Lock")
awful.spawn.with_shell(" xset r rate 400 25")
--awful.spawn.with_shell("xmodmap ~/.Xmodmap")
--awful.spawn.with_shell("~/scripts/startups/poly_start.sh")
--awful.spawn.with_shell("rclone mount Shri77_Photos: Pictures/g-photos/")
