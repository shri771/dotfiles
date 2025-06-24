local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome libary
local gears = require("gears") --Utilities such as color parsing and objects
local awful = require("awful") --Everything related to window managment
require("awful.autofocus")
awful.util.spawn("xprop -root -f _NET_NUMBER_OF_DESKTOPS 32c -set _NET_NUMBER_OF_DESKTOPS 5")
require("lua.autostart")

-- at the top:
-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
beautiful.useless_gap = 19
-- Notification library
local naughty = require("naughty")
naughty.config.defaults["icon_size"] = 100
naughty.config.defaults.replaces_id = 1

local lain = require("lain")
local freedesktop = require("freedesktop")
local bling = require("bling")

-- Enable hotkeys help widget for VIM and other apps
--when client with a matching name is opened:
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

-- Tags
awful.util.tagnames = { "   ", "   ", "   ", "   ", "   ", "󰗃 ", " " }

awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max,
  awful.layout.suit.magnifier,
  bling.layout.mstab,
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
  end)
  -- awful.button({}, 4, awful.tag.viewnext),
  -- awful.button({}, 5, awful.tag.viewprev)
))

-- Volume notification --
local ICON_DIR = os.getenv("HOME") .. "/.config/swaync/icons"
local function get_volume_icon(vol, muted)
  if muted then
    return ICON_DIR .. "/volume-mute.png"
  end

  vol = tonumber(vol) or 0
  if vol <= 30 then
    return ICON_DIR .. "/volume-low.png"
  elseif vol <= 60 then
    return ICON_DIR .. "/volume-mid.png"
  else
    return ICON_DIR .. "/volume-high.png"
  end
end

local function notify_volume()
  local channel = beautiful.volume.channel or "Master"
  awful.spawn.easy_async_with_shell("amixer get " .. channel, function(stdout)
    local vol = tonumber(stdout:match("(%d?%d?%d)%%")) or 0
    local status = stdout:match("%[(%a+)%]") or "on"
    local muted = status:lower() ~= "on"

    local old_margin = naughty.config.defaults.margin or 0
    naughty.config.defaults.margin = 20
    -- this is where vol & muted exist!
    naughty.notify({
      title = "Volume",
      text = muted and "Muted" or (vol .. "%"),
      icon = get_volume_icon(vol, muted),
      timeout = 1.5,
      width = 250,
      position = "top_middle",
    })
    naughty.config.defaults.margin = old_margin
  end)
end
local volume_channel = beautiful.volume.channel or "Master"
local toggle_channel = beautiful.volume.togglechannel or volume_channel

-- Brightness notification
local brightness_notification
local icon_dir = os.getenv("HOME") .. "/.config/swaync/icons"

local function notify_brightness()
  awful.spawn.easy_async_with_shell("brightnessctl get", function(get_out)
    awful.spawn.easy_async_with_shell("brightnessctl max", function(max_out)
      local cur = tonumber(get_out:match("%d+")) or 0
      local max = tonumber(max_out:match("%d+")) or 1
      local pct = math.floor(cur / max * 100)

      -- Select icon based on percentage
      local icon = icon_dir .. "/brightness-100.png"
      if pct < 30 then
        icon = icon_dir .. "/brightness-30.png"
      elseif pct < 70 then
        icon = icon_dir .. "/brightness-60.png"
      end

      local old_margin = naughty.config.defaults.margin or 0
      naughty.config.defaults.margin = 20
      -- Replaces old notification if it exists
      brightness_notification = naughty.notify({
        title = "Brightness",
        text = pct .. "%",
        icon = icon,
        timeout = 1.5,
        replaces_id = brightness_notification and brightness_notification.id or nil,
        width = 250,
        position = "top_middle",
      })
      naughty.config.defaults.margin = old_margin
    end)
  end)
end

-- Keybindings
globalkeys = my_table.join(
  -- Brightness
  awful.key({}, "XF86MonBrightnessUp", function()
    os.execute("brightnessctl set +10%")
    notify_brightness()
  end, { description = "increase brightness + show notification", group = "custom widgets" }),
  awful.key({}, "XF86MonBrightnessDown", function()
    os.execute("brightnessctl set 10%-")
    notify_brightness()
  end, { description = "decrease brightness + show notification", group = "custom widgets" }),

  -- Volume
  awful.key({}, "XF86AudioRaiseVolume", function()
    os.execute(string.format("amixer -q set %s unmute", volume_channel))
    os.execute(string.format("amixer -q set %s 5%%+", volume_channel))
    notify_volume()
  end, { description = "volume up (and unmute)", group = "custom widgets" }),
  awful.key({}, "XF86AudioLowerVolume", function()
    os.execute(string.format("amixer -q set %s 5%%-", volume_channel))
    notify_volume()
  end, { description = "volume down", group = "custom widgets" }),
  awful.key({}, "XF86AudioMute", function()
    os.execute(string.format("amixer -q set %s toggle", toggle_channel))
    notify_volume()
  end, { description = "toggle mute", group = "custom widgets" }),

  -- Launcher
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end, { description = "Launch terminal", group = "awesome" }),
  awful.key({ modkey }, "f", function()
    awful.spawn("dolphin")
  end, { description = "Launch fm", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "o", function()
    awful.spawn("flameshot gui")
  end, { description = "Take a screenshot with Flameshot", group = "hotkeys" }),
  awful.key({ modkey }, "o", function()
    awful.spawn("flameshot full")
  end, { description = "Take a screenshot with Flameshot", group = "hotkeys" }),
  awful.key({ altkey }, "n", function()
    awful.spawn("notion-app")
  end, { description = "Launch Notion", group = "hotkeys" }),
  -- awful.key({ modkey }, "q", function()
  --   awful.spawn("rquickshare")
  -- end, { description = "Launch quickshare", group = "hotkeys" }),
  awful.key({ modkey }, "v", function()
    awful.spawn("code")
  end, { description = "Launch VSCode", group = "hotkeys" }),
  awful.key({ modkey }, "b", function()
    awful.spawn("brave")
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
  awful.key({ modkey, "Shift" }, "q", function() -- Mod1 = Alt key
    awful.spawn.with_shell("$HOME/.config/awesome/scripts/KillActive_process.sh &")
  end),
  awful.key({ modkey, "Shift" }, "space", function() -- Mod1 = Alt key
    awful.spawn.with_shell("$HOME/.config/awesome/scripts/toggle_layout.sh ")
  end),
  awful.key({ altkey, "Control" }, "p", function()
    awful.spawn.with_shell("wlogout")
  end),
  awful.key({ altkey, "Control" }, "Delete", function()
    awful.spawn.with_shell("awesome-client 'awesome.quit()'")
  end),
  awful.key({ altkey }, "Left", function()
    awful.tag.viewprev()
  end, { description = "view previous workspace", group = "tag" }),
  awful.key({ altkey }, "Right", function()
    awful.tag.viewnext()
  end, { description = "view next workspace", group = "tag" }),
  -- NormCap screenshot and OCR (Mod + A)
  awful.key({ modkey }, "a", function()
    awful.util.spawn("normcap -c '#aa55ff' -t False")
  end, { description = "OCR screenshot (no text mode)", group = "custom" }),
  awful.key(
    {}, -- no modifiers
    "XF86TouchpadToggle", -- or whatever keysym `xev` showed you
    function()
      -- directly call notify-send without shell quoting headaches
      awful.spawn.with_shell("/usr/bin/notify-send", {
        "--app-name=System",
        "--icon=" .. os.getenv("HOME") .. "/.config/awesome/icons/touchpad.svg",
        "System",
        "Touchpad Disabled",
      })
    end,
    { description = "notify touchpad disabled", group = "custom" }
  ),

  -- Rofi launcher's
  awful.key({ altkey }, "f", function()
    awful.spawn("rofi -show drun -modi drun,run,window,filebrowser")
  end, { description = "launch rofi", group = "launcher" }),
  awful.key({ altkey }, "u", function()
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
  end, { description = "dropdown application", group = "super" })

  --]]
)

-- dropdown
-- Scratchpad

-- 1. your cycle function

local function cycle_maximized_client()
  local c = client.focus
  if not c then
    return
  end

  -- Don’t touch fullscreen clients
  if c.fullscreen then
    return
  end

  if c.maximized then
    local clients = awful.screen.focused().clients
    if #clients <= 1 then
      return
    end

    -- find index of current
    local idx
    for i, cl in ipairs(clients) do
      if cl == c then
        idx = i
        break
      end
    end

    local next_idx = (idx % #clients) + 1
    local nc = clients[next_idx]

    -- un-maximize old, maximize new
    c.maximized = false
    c.floating = false

    nc.floating = false
    nc.maximized = true
    nc:raise()
    client.focus = nc
  else
    -- wasn’t maximized → maximize it
    c.maximized = true
    c:raise()
  end
end

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

      -- **Zero out the border so there's no border on the scratchpad**
      c.border_width = 0

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
  awful.key({ modkey, "Control" }, "Return", toggle_terminal, { description = "...", group = "scratchpads" }),
  awful.key({ altkey }, "d", toggle_pavcontrol, { description = "...", group = "scratchpads" }),
  awful.key({ altkey }, "g", toggle_resources, { description = "...", group = "scratchpads" }),
  awful.key({ altkey }, "c", toggle_cal, { description = "...", group = "scratchpads" }),
  awful.key({ altkey }, "o", toggle_cal, { description = "...", group = "scratchpads" }),
  awful.key({ altkey }, ",", toggle_clock, { description = "...", group = "scratchpads" }),
  awful.key({ modkey }, ",", toggle_whatsie, { description = "...", group = "scratchpads" }),
  awful.key({}, "XF86AudioPlay", function()
    awful.spawn("playerctl play-pause")
  end),
  awful.key({}, "XF86AudioNext", function()
    awful.spawn("playerctl next")
  end),
  awful.key({}, "XF86AudioPrev", function()
    awful.spawn("playerctl previous")
  end),
  awful.key({ altkey }, "p", toggle_kdeconnect, { description = "...", group = "scratchpads" }),
  awful.key(
    { "Control" },
    "Tab",
    cycle_maximized_client,
    { description = "cycle fullscreen clients / toggle fullscreen", group = "client" }
  )
)

-- Function to set wallpaper by reading the path from the file
local function set_wallpaper(s)
  local wallpaper_file = io.open(os.getenv("HOME") .. "/.config/awesome/wallpaper_path", "r")
  if wallpaper_file then
    local path = wallpaper_file:read("*all"):gsub("%s+$", "") -- Read and trim whitespace
    wallpaper_file:close()
    if path and path ~= "" then
      gears.wallpaper.maximized(path, s)
    end
  end
end

-- local wallpaper_path = "~/Pictures/wallpapers/IT_guy.png" -- Replace with the actual path
--
-- client.connect_signal("property::maximized", function(c)
--   if c.class == "kitty" then
--     if c.maximized then
--       os.execute("kitten @ set-background-image " .. wallpaper_path .. " --os-window-id " .. c.window)
--     else
--       os.execute("kitten @ set-background-image none --os-window-id " .. c.window)
--     end
--   end
-- end)
-- Set wallpaper for each screen initially
screen.connect_signal("request::wallpaper", set_wallpaper)
clientkeys = my_table.join(
  awful.key({ modkey }, "space", function(c)
    -- if it’s maximized, bail out
    if c.maximized then
      return
    end

    -- otherwise, flip fullscreen
    c.fullscreen = not c.fullscreen
    c:raise()

    if not c.fullscreen then
      set_wallpaper(c.screen)
    end
  end, { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey }, "q", function(c)
    c:kill()
  end, { description = "close", group = "hotkeys" }),
  awful.key({ modkey }, "p", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
  awful.key({ altkey, ctrlkey }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" }),
  awful.key({ modkey, "Shift" }, "t", function(c)
    c.ontop = not c.ontop
  end, { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey }, "m", function(c)
    -- if it's fullscreen, do nothing
    if c.fullscreen then
      return
    end

    -- otherwise, flip maximize
    c.maximized = not c.maximized
    c:raise()
  end, { description = "maximize", group = "client" })
)

-- Bind tags to shortcut's
-- Define letter shortcuts for workspaces 1, 2, and 3

local letterKeys = { "t", "n", "s" }

for i = 1, 9 do
  -- only show #1 and #9 in the shortcut help
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = { description = "view tag #", group = "tag" }
    descr_toggle = { description = "toggle tag #", group = "tag" }
    descr_move = { description = "move focused client to tag #", group = "tag" }
    descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
  end

  -- map number keys to tag indices
  local adjusted_key = i
  -- shift tags 4–6 up to 7–9
  if i >= 4 and i <= 6 then
    adjusted_key = i + 3
  end
  -- special case: make Mod+0 go to tag index 7
  if i == 7 then
    adjusted_key = 10 -- maps to keycode #19 → the “0” key
  end

  globalkeys = my_table.join(
    globalkeys,
    -- view tag only (number row)
    awful.key({ modkey }, "#" .. (adjusted_key + 9), function()
      local tag = awful.screen.focused().tags[i]
      if tag then
        tag:view_only()
      end
    end, descr_view),

    -- toggle tag display
    awful.key({ modkey, ctrlkey }, "#" .. (adjusted_key + 9), function()
      local tag = awful.screen.focused().tags[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, descr_toggle),

    -- move client to tag
    awful.key({ modkey, "Shift" }, "#" .. (adjusted_key + 9), function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, descr_move),

    -- toggle focused client on tag
    awful.key({ modkey, ctrlkey, "Shift" }, "#" .. (adjusted_key + 9), function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, descr_toggle_focus)
  )

  -- letter-key shortcuts for tags 1–3
  if i <= 3 then
    local letter_descr = { description = "tag #" .. i, group = "tag" }
    globalkeys = my_table.join(
      globalkeys,
      awful.key({ modkey }, letterKeys[i], function()
        local tag = awful.screen.focused().tags[i]
        if tag then
          tag:view_only()
        end
      end, letter_descr),
      awful.key({ modkey, ctrlkey }, letterKeys[i], function()
        local tag = awful.screen.focused().tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end, letter_descr),
      awful.key({ modkey, "Shift" }, letterKeys[i], function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end, letter_descr),
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
local clientbuttons = gears.table.join(
  -- Left click to focus + raise
  awful.button({}, 1, function(c)
    client.focus = c
    c:raise()
  end),

  -- Modkey + left‐drag to move
  awful.button({ modkey }, 1, function(c)
    awful.mouse.client.move(c)
  end),

  -- Modkey + right‐drag to resize
  awful.button({ modkey }, 3, function(c)
    awful.mouse.client.resize(c)
  end),

  -- **Plain right‐drag to resize (no modifier)**
  awful.button({ modkey }, 3, function(c)
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)

-- Window's Rules
awful.rules.rules = {
  --Apply border color , width and more
  {
    rule = {},
    except_any = { -- <<< changed here
      class = { "Polybar" },
    },
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

  -- Open poup's in center of Window
  {
    rule_any = {
      type = { "dialog", "utility", "splash" },
      role = { "pop-up", "GtkFileChooserDialog" },
      name = { "Preferences", "Options" },
    },
    except_any = { -- <<< changed here
      class = { "Polkit-gnome-authentication-agent-1", "kdialog", "Xdg-desktop-portal-gtk" },
    },
    instance = {
      "kdialog",
    },
    properties = {
      floating = true,
      ontop = true,
    },
    callback = function(c)
      local f = client.focus
      if f then
        local fg = f:geometry()
        local cg = c:geometry()

        local nx = fg.x + math.floor((fg.width - cg.width) / 2)
        local ny = fg.y + math.floor((fg.height - cg.height) / 2)

        c:geometry({
          x = nx,
          y = ny,
          width = cg.width,
          height = cg.height,
        })
      else
        awful.placement.centered(c, { honor_workarea = true })
      end
    end,
  },

  -- Polybar
  {
    rule_any = {
      class = { "Polybar" },
    },
    properties = {
      floating = ture,
      below = true,
    },
  },

  -- Rules to open a app in sepcific Tag
  { rule = { class = "vlc" }, properties = { tag = awful.screen.focused().tags[5] } },
  {
    rule = { class = "autokey-qt" },
    properties = { tag = awful.screen.focused().tags[7] },
  },
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

  -- Floting Windows
  { rule = { class = "Rquickshare" }, properties = { floating = true } },
  {
    rule_any = { class = { "kdialog", "Xdg-desktop-portal-gtk" } },
    properties = {
      floating = true,
      ontop = true,
      placement = awful.placement.centered,
      width = 550,
      height = 440,
    },
    callback = function(c)
      -- Force geometry before placement
      c:geometry({ width = 800, height = 570 })
      -- Recenter after geometry is set
      awful.placement.centered(c, { honor_workarea = true })
    end,
  },
  {
    rule = { class = "Brave-browser", instance = "crx_nngceckbapebfimnlniiiahkandclblb" },
    properties = {
      floating = true,
      ontop = true,
    },
  },

  -- Floating Window's with fixed size
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
        "qt5ct",
        "qt6ct",
      },
    },
    properties = { floating = true, ontop = true },
    callback = function(c)
      c:geometry({ width = 550, height = 440 })
      awful.placement.centered(c, { honor_workarea = true })
    end,
  },

  { rule = { class = "VirtualBox Manager" }, properties = { maximized = false } },

  { rule = { class = "Xfce4-settings-manager" }, properties = { floating = false } },
}

-- bind it: Mod4 + F11
-- Allow client to switch Workspace
client.connect_signal("request::activate", function(c, context, hints)
  -- Only handle Brave-browser
  if c.class ~= "Brave-browser" then
    return
  end

  -- only switch if the client isn't already visible
  if not c:isvisible() then
    -- 1) Clear fullscreen on **all** clients
    local all_clients = client.get()
    for i = 1, #all_clients do
      if all_clients[i].fullscreen then
        all_clients[i].fullscreen = false
      end
    end

    -- 2) Switch to this client's first tag
    local tags = c:tags()
    if tags and tags[1] then
      awful.tag.viewonly(tags[1])
      -- Force layout rearrangement to re-apply rules cleanly
      awful.layout.arrange(tags[1].screen)
    end
  end

  -- 3) Focus & raise
  client.focus = c
  c:raise()

  -- 4) Remove border if client is floating
  if c.floating then
    c.border_width = 0
  end
end)

-- client.connect_signal("property::floating", function(c)
--   if c.floating then
--     c.border_width = 0
--   else
--     c.border_width = beautiful.border_width
--   end
-- end)

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

-- Notification --

-- Set default notification settings
naughty.config.defaults.timeout = 3
naughty.config.defaults.margin = 8
naughty.config.defaults.spacing = 6
naughty.config.defaults.icon_size = 35
naughty.config.defaults.position = "top_middle"
naughty.config.defaults.shape = gears.shape.rounded_rect
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.padding = 20 -- padding for notifications
beautiful.notification_opacity = 0.95

-- Wrap naughty.notify so each new notif nukes the last one
do
  local orig_notify = naughty.notify
  local last_id = nil

  naughty.notify = function(opts)
    -- force replacement of the last notification
    opts.replaces_id = last_id
    -- fire off the real notify; it returns the notif object
    local n = orig_notify(opts)
    -- stash its ID for next time
    last_id = n.id
    return n
  end
end

-- block Notification
local blocked_apps = {
  ["blueman"] = true,
  ["networkmanager"] = true, -- example: block any NM notifications
  -- add more keys here, e.g. ["someapp"] = true,
}

local orig_notify = naughty.notify
naughty.notify = function(args)
  if args.app_name then
    local app = args.app_name:lower()
    if blocked_apps[app] then
      return
    end
  end

  return orig_notify(args)
end
